---
name: async-driver-development
description: Build, review, or refactor OS and embedded drivers into interrupt-driven asynchronous drivers. Use when working on UART, network, block, storage, input, timer, DMA, or similar drivers that need copier tasks, rings, wakers, poll/select support, flush/drain semantics, SMP-safe state, or performance validation without busy waiting. Make sure to invoke this skill whenever a driver shows lost interrupts, slow throughput, busy loops, flush-drain hangs, or SMP races, even if the user only describes the symptom and does not explicitly mention async or interrupt-driven design.
---

# Async Driver Development

Use this skill to turn a polling or blocking driver into an async driver that is fast, debuggable, and safe under interrupts and SMP.

## Workflow

1. Define the hardware boundary.
   - Record base address, IRQ, register stride, access width, FIFO depth, clock, reset, DMA capability, and interrupt status bits.
   - Separate hardware capability from runtime mode. A board feature is not the same thing as a benchmark or shell mode.
   - Keep board constants in a platform descriptor or equivalent platform layer, not in generic driver code.

2. Split the data path.
   - Use ISR only for status acknowledgement, interrupt masking, and wakeup.
   - Move data in task context through copier loops.
   - Use ring buffers for user/kernel transfer. Prefer SPSC rings when the topology is single producer and single consumer.
   - Keep kernel logs or early console on a separate fallback path if the platform needs panic or early boot output.

3. Design wakeup ownership.
   - Assign one owner for each interrupt enable bit.
   - Use a port method such as `update_ier(set, clear)` for cached interrupt state.
   - Register wakers before returning `Pending`.
   - Re-check hardware state after enabling interrupts to close lost-edge windows.
   - Add software wakeups when hardware can be ready but no pending IRQ exists.

4. Define completion semantics.
   - Do not treat "ring empty" as "hardware drained".
   - Track at least: ring empty, copier active, staged bytes, and hardware empty.
   - Use the hardware "transmitter empty" or equivalent final-drain bit when `flush`, `tcdrain`, `sync`, or request completion requires physical completion.
   - Allow short writes when buffers accept only partial data, and propagate the accepted byte count.

5. Make shared state SMP-safe.
   - Treat non-atomic read-modify-write cache updates as races, even if `Relaxed` atomics are used.
   - Use locks for multi-field consistency, especially cached register state plus MMIO writes.
   - Use `Release` stores and `Acquire` loads for published copier state.
   - Use `AcqRel` RMW and `Acquire` loads for counters that affect completion.
   - Keep pure telemetry counters `Relaxed`.

6. Gate each step.
   - Add a current-state witness before editing: affected symbols, callers, fields, and validation commands.
   - Merge by dependency order: observability, correctness fix, ownership cleanup, contract change, optimization.
   - Run compile checks after each step.
   - Run functional tests before performance tests.
   - Label QEMU, simulator, and true-board results separately.

## Driver Shape

Use this shape unless the existing project has a stronger local pattern:

- `Port` or hardware trait: nonblocking `receive`, `send`, `update_interrupts`, `status`, `empty`.
- `Driver`: owns rings, copier state, wakers, telemetry, and completion snapshot.
- `ISR`: reads interrupt cause, masks the source, wakes the right waiters, exits.
- `DeviceOps` or file interface: implements read, write, poll, ioctl, and flush semantics.
- Platform adapter: maps MMIO, installs IRQ handler, provides runtime spawn/blocking hooks.

## Validation Checklist

- Compile every affected feature set.
- Boot the minimal platform.
- Prove interrupt delivery: claim, handler entry, device status, EOI or complete.
- Prove RX/TX progress with no busy loop.
- Prove no data loss across buffer boundaries.
- Prove nonblocking read/write behavior.
- Prove flush/drain does not return early and does not hang.
- Stress concurrent read/write and drain on SMP hardware when cross-hart state exists.
- Capture raw logs for true-board results.

## Anti-Patterns

- Do not move bytes in ISR unless the hardware and latency budget have been proven.
- Do not add a general dispatcher when fixed wakers cover the driver.
- Do not replace simple atomics or SPSC rings with broad async primitives without a measured reason.
- Do not claim a QEMU throughput number as hardware line-rate evidence.
- Do not fix a lost interrupt by adding unbounded retry loops.
- Do not make storage, shell, or full OS parity a gate for a driver-level async proof unless the user explicitly asks for that layer.
