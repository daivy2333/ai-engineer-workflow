---
name: async-driver-development
description: Build, review, or refactor OS and embedded drivers into interrupt-driven asynchronous drivers. Use when working with UART, network, block, storage, input, timer, DMA, or similar drivers that need copier tasks, rings, queue services, wakers, poll/select support, flush/drain semantics, device recovery (reset, link flap), SMP-safe state, or performance validation without busy waiting. Make sure to invoke this skill whenever a driver shows lost interrupts, slow throughput, busy loops, flush-drain hangs, SMP races, or reset and link-flap failures, even if the user only describes the symptom and does not explicitly mention async or interrupt-driven design.
---

# Async Driver Development

Use this skill to turn a polling or blocking driver into an async driver that is fast, debuggable, safe under interrupts and SMP, and survives reset and link events.

Read the references that match the work:

- Packet or descriptor devices (network, block, storage controllers): [references/queue-service-layers.md](references/queue-service-layers.md).
- Any driver that must survive device reset, link flap, or hot removal: [references/device-recovery-semantics.md](references/device-recovery-semantics.md).
- Host-side tests for driver or queue logic: [references/driver-host-fixtures.md](references/driver-host-fixtures.md).

## Workflow

1. Define the hardware boundary.
   - Record base address, IRQ, register stride, access width, FIFO or queue depth, clock, reset, DMA capability, and interrupt status bits.
   - Separate hardware capability from runtime mode. A board feature is not the same thing as a benchmark or shell mode.
   - Keep board constants in a platform descriptor or equivalent platform layer, not in generic driver code.

2. Split the data path by device class.
   - Byte-stream devices: ISR only for status acknowledgement, interrupt masking, and wakeup; move data in task context through copier loops; use SPSC rings for user/kernel transfer; keep kernel logs or early console on a separate polling fallback path.
   - Packet or descriptor devices: split into four execution layers — hard IRQ (cause/ack/mask/wake), a queue task with a bounded budget (reap/refill/reclaim over fixed-capacity slots), a single resident stack or service runner that owns protocol-state mutation, and a readiness bridge that fans out per-waiter wakeups. The ownership unit is the packet buffer plus its descriptor, not bytes.
   - Wake order follows the layers: IRQ wakes the queue task; the queue task wakes the runner and the waiters on readiness change. Waking a runner or socket directly from IRQ leaves descriptors unowned.

3. Design wakeup ownership.
   - Assign one owner for each interrupt enable bit. Use a port method such as `update_ier(set, clear)` for cached interrupt state.
   - Register one handler per device IRQ on the platform's device handler table and check the registration result: a failed registration is an init failure, not a degraded async mode. Do not let correctness depend on a single-slot global hook shared across devices — registration order must not decide which device silently loses its wakeups.
   - Treat masking as a loss budget, not correctness: a masked source can drop edge or MSI events. Mask after a trigger, re-check state after unmask, and add software wakeups when hardware can be ready with no pending IRQ.
   - For write-to-clear or clear-on-read cause registers, snapshot before acking and accumulate causes across one IRQ.
   - Register wakers before returning `Pending`, and re-check hardware state after enabling or rearming interrupts to close lost-edge windows. On transports that suppress notifications (used-event/avail-event style), rearm is separate from unmask and needs its own recheck.

4. Define completion semantics.
   - Do not treat "ring empty" as "hardware drained".
   - Byte-stream devices: track at least ring empty, copier active, staged bytes, and hardware empty; use the hardware "transmitter empty" or equivalent final-drain bit when `flush`, `tcdrain`, `sync`, or request completion requires physical completion; allow short writes when buffers accept only partial data, and propagate the accepted count.
   - Packet devices: accepted, device-completed, and reclaimed are distinct states; completion is proven where the slot and descriptor ledger says the slot returned, never by an IRQ cause. Flush is ticketed (request → release → confirm) and can be terminally aborted.
   - Bound the progress ladder on every wait: bounded fast retry, then register + arm + recheck, then a bounded slow-poll or NAPI-style polling mode entered on sustained readiness and exited on zero progress, then yield, then pure ISR wait. No stage becomes an unbounded loop.

5. Make shared state SMP-safe.
   - Treat non-atomic read-modify-write cache updates as races, even if `Relaxed` atomics are used.
   - Use locks for multi-field consistency, especially cached register state plus MMIO writes.
   - Use `Release` stores and `Acquire` loads for published copier or queue state; `AcqRel` RMW and `Acquire` loads for counters that affect completion; keep pure telemetry counters `Relaxed`.
   - Pin single-owner contexts (queue owner, stack runner) to fixed cores; route cross-core wakeups through the platform's directed wakeup (IPI) mechanism.

6. Define recovery semantics before performance.
   - Layer generations across queue, link, and waiter state; rebuild queues in place on reset; discard late completions by epoch; release DMA backing only with proof of quiesce.

7. Gate each step.
   - Add a current-state witness before editing: affected symbols, callers, fields, and validation commands.
   - Merge by dependency order: observability, correctness fix, ownership cleanup, contract change, optimization.
   - Run compile checks after each step.
   - Run functional tests before performance tests; prove recovery before long-run claims.
   - Label QEMU, simulator, and true-board results separately.

## Driver Shape

Use the shape that matches the device class unless the existing project has a stronger local pattern.

Byte-stream driver:

- `Port` or hardware trait: nonblocking `receive`, `send`, `update_interrupts`, `status`, `empty`.
- `Driver`: owns rings, copier state, wakers, telemetry, and completion snapshot.
- `ISR`: reads interrupt cause, masks the source, wakes the right waiters, exits.
- `DeviceOps` or file interface: implements read, write, poll, ioctl, and flush semantics.
- Platform adapter: maps MMIO, installs IRQ handler, provides runtime spawn/blocking hooks.

Packet or descriptor driver:

- Device IRQ control seam: read cause, ack, mask, rearm, snapshot counters, wake the queue owner — nothing else runs in interrupt context.
- Queue service: one owner per hardware queue; fixed-capacity RX/TX slots; publish/reap/refill/wrap; typed backpressure; slot and descriptor ledger.
- Resident stack or service runner: the only context that mutates protocol or service state.
- Readiness bridge: per-waiter wake, multi-waiter fan-out, accept bridging, terminal fault publication.
- Platform and transport adapter: maps probe, IRQ routing, DMA, and cache maintenance into the queue contract; queue semantics never leak into the transport.

## Validation Checklist

- Compile every affected feature set.
- Boot the minimal platform.
- Prove interrupt delivery: claim, handler entry, device status, EOI or complete.
- Prove RX/TX progress with no busy loop; prove budget and yield under sustained input.
- Prove no data loss across buffer boundaries; slot and descriptor counts conserve on every error path.
- Prove nonblocking read/write behavior.
- Prove flush/drain does not return early and does not hang; a ticketed flush closes or aborts with a terminal result.
- Prove recovery: reset and link-flap matrices, late completions discarded by epoch, no double reclaim, no permanent Pending, backing retained while quiesce is unproven.
- Prove quiet with a settle phase: counters must stay flat for a fixed window before they are frozen as the quiet witness.
- Stress concurrent read/write and drain on SMP hardware when cross-hart state exists.
- Drive queue and ownership logic through a host fixture (fake transport, device-side completion simulation) before guest or board runs.
- Capture raw logs for true-board results.

## Anti-Patterns

- Do not move bytes in ISR unless the hardware and latency budget have been proven.
- Do not add a general dispatcher when fixed wakers cover the driver.
- Do not replace simple atomics or SPSC rings with broad async primitives without a measured reason.
- Do not claim a QEMU throughput number as hardware line-rate evidence.
- Do not fix a lost interrupt by adding unbounded retry loops.
- Do not make storage, shell, or full OS parity a gate for a driver-level async proof unless the user explicitly asks for that layer.
- Do not let a resident runner re-arm itself every packet while its wake condition is unmet — combined with a spin lock and round-robin scheduling, this self-wake storm starves the very waiters it owes a bounded failure.
- Do not release DMA backing because a reset completed cleanly; without proof that the device stopped mastering the bus, keep the faulted owner, retain the backing, and refuse new submissions.
