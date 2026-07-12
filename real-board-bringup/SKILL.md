---
name: real-board-bringup
description: Plan, execute, or debug physical-board kernel and driver bring-up. Use when a task involves boot images, bootloader handoff, early serial output, device-tree or board facts, MMIO register access, clock or reset state, PLIC or interrupt delivery, hart topology, storage or rootfs bring-up, or true-board workload validation. Make sure to invoke this skill whenever the user is on real hardware and reports 'board won't boot', 'no serial output', 'register reads all zero', or similar bring-up symptoms, even if they do not name the bring-up phase or platform directly.
---

# Real Board Bring-Up

Use this skill to debug real hardware by building evidence in layers. Do not start with a full OS workload.

## Layered Gates

1. Boot image gate.
   - Prove the bootloader loads the image.
   - Record image format, load address, entry, size, and boot command.
   - Keep flashing manual unless the project already has a safe scripted flow.

2. First-byte gate.
   - Add a polling early console that needs no tasks, interrupts, rootfs, heap-heavy services, or async driver.
   - Print board name, boot hart, DTB or platform source, memory range, and MMIO range.
   - Treat first serial output as a separate success from driver success.

3. Platform facts gate.
   - Confirm hart count, boot hart, ISA differences, memory map, interrupt controller, UART or target device base, IRQ, stride, access width, clock, reset, and FIFO or queue depth.
   - Do not assume hart 0 is the usable main core.
   - Do not infer access width from register stride.

4. Register-access gate.
   - Read identity, status, and control registers before running workloads.
   - Record original values and write-readback values.
   - If registers read all zero or all ones, stop and debug mapping, clock, reset, privilege, or bus access first.

5. Interrupt gate.
   - Split interrupt validation into claim, handler entry, device status clear, and EOI or complete.
   - Prove repeated interrupts, not just one interrupt.
   - Keep handler logs small and gated.

6. Minimal function gate.
   - Run a kernel-level operation that uses the driver but avoids unrelated subsystems.
   - For UART, prove RX, TX, wakeups, and drain before shell or rootfs.
   - For network or block, prove descriptor/ring movement before protocol or filesystem.

7. Workload gate.
   - Add user workload only after lower gates pass.
   - Keep benchmark mode, shell mode, rootfs mode, and storage mode separate.
   - Preserve raw board logs and label board, mode, payload, and timer source.

## Trusting Bootloader State

Use bootloader state carefully:

- Dump current clock, reset, interrupt, pinmux, and device status before changing it.
- Preserve known-good bootloader setup when reinitialization is risky.
- Make minimal changes and let lower gates decide.
- Do not generalize one device's rule to all devices. UART FIFO, interrupt enable, and baud setup are often safe to reinitialize; PHY and clock trees may not be.

## Failure Triage

- No output: inspect image format, load address, entry, early console base/stride/width, and boot command.
- Fault after first output: inspect page tables, memory attributes, stack, relocation, and final address-space switch.
- Registers all zero: inspect MMIO mapping, clocks, reset, access width, and privilege.
- One interrupt only: inspect device status clear and EOI/complete.
- Workload hangs: step back to register, interrupt, queue, and wakeup gates.
- Performance oddity: compare against physical line rate or bus limit, not simulator numbers.

## Evidence Rules

- Record exact board, firmware, boot command, image name, and build feature set.
- Keep raw logs near the analysis.
- Label skipped gates with concrete blockers.
- Do not call a skipped shell, rootfs, or storage path a driver failure.
- Do not claim SMP validation until the workload actually ran on the relevant harts.
