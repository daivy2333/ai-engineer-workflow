---
name: real-board-bringup
description: Plan, execute, or debug physical-board kernel and driver bring-up. Use when a task involves boot images, bootloader handoff, early serial output, device-tree or board facts, MMIO register access, clock or reset state, PLIC or MSI-style interrupt delivery, DMA arena setup, hart or cluster topology, storage or rootfs bring-up, or true-board workload validation. Make sure to invoke this skill whenever the user is on real hardware and reports 'board won't boot', 'no serial output', 'register reads all zero', 'interrupts fire once then stop', 'device goes silent after replug', or similar bring-up symptoms, even if they do not name the bring-up phase or platform directly.
---

# Real Board Bring-Up

Use this skill to debug real hardware by building evidence in layers. Do not start with a full OS workload.

## Bring-up strategy: reversible first

- Prefer a reversible boot path over flashing: load the image into RAM from the bootloader (USB, network, or removable media) and boot it temporarily. The stock system stays intact as both the recovery path and the observation platform.
- Never persist bootloader environment changes during bring-up; at any moment a reset returns to the stock system.
- Keep flashing as the late exception, not the default. Before the first flash, back up the boot partitions.

## Layered Gates

1. Boot image gate.
   - Prove the bootloader loads the image. Record image format, load address, entry, size, and boot command.
   - Learn the vendor's bootloader entry method (a held key at reset, a break key, or a console escape) and document it once.
   - Watch load-address conflicts: bootloader default load addresses can overlap reserved regions (CMA, carveouts, allocator windows). Pick an address in a proven-safe window and keep it fixed.
   - Handle device-tree relocation explicitly; some boot paths must pin the FDT in place or it is unmapped mid-boot. File names on boot media are often case-sensitive.
   - Keep flashing manual unless the project already has a safe scripted flow.

2. Stock-OS observation gate.
   - Run statically linked probe binaries on the board's stock OS (USB or network transfer) to collect board facts: device nodes, memory layout, peripheral visibility, stock driver behavior. Use static binaries; dynamic ones assume the stock libc matches your toolchain.
   - Copy binaries to a writable local filesystem before executing; FAT-mounted files cannot be trusted with exec bits.

3. First-byte gate.
   - Add a polling early console that needs no tasks, interrupts, rootfs, heap-heavy services, or async driver.
   - Print board name, boot hart, DTB or platform source, memory range, and MMIO range.
   - Treat first serial output as a separate success from driver success.

4. Platform facts gate.
   - Confirm hart count, boot hart, ISA and core-type differences, memory map, interrupt controller, UART or target device base, IRQ, stride, access width, clock, reset, and FIFO or queue depth.
   - Do not assume hart 0 is the usable main core. Do not assume symmetric cores: on asymmetric or clustered topologies, a cross-cluster or little-core fetch can fault where local cores do not.
   - Interrupt controllers differ: PLIC-style claim/complete, MSI-based delivery with an atomic claim+EOI before the handler, or vendor glue. Record the claim, dispatch, and completion mechanism as platform facts before enabling any device IRQ.

5. Register-access gate.
   - Read identity, status, and control registers before running workloads. Record original values and write-readback values.
   - If registers read all zero or all ones, stop and debug mapping, clock, reset, privilege, or bus access first.

6. Interrupt gate.
   - Split interrupt validation into claim, handler entry, device status clear, and EOI or complete.
   - Prove repeated interrupts, not just one. A single-shot interrupt usually means a status-clear or completion step is wrong.
   - For write-to-clear or clear-on-read causes: snapshot before acking, accumulate causes across one IRQ, and exclude echo or null-cause claims with a classifier.
   - Masking windows drop edge or MSI events: mask after a trigger, treat masks as a loss budget, and re-check after unmask. Latched level sources need an ack-by-read consumer; some reset defaults hold clears (hold-in-clear) and must be released explicitly.
   - Keep handler logs small and gated; apply a storm budget so a misbehaving source cannot wedge the console.

7. DMA and memory gate.
   - Before any dataplane: define the exclusive DMA arena, address translation, cache maintenance ordering (publish before submit, reclaim before reuse), and wrap or boundary checks.
   - Retain published backing until the device is proven quiesced; on unproven quiesce keep the faulted owner and refuse new submissions.

8. Minimal function gate.
   - Run a kernel-level operation that uses the driver but avoids unrelated subsystems.
   - For UART, prove RX, TX, wakeups, and drain before shell or rootfs.
   - For network or block, prove descriptor or ring movement before protocol or filesystem.

9. Workload gate.
   - Add user workload only after lower gates pass.
   - Keep benchmark mode, shell mode, rootfs mode, and storage mode separate.
   - Preserve raw board logs and label board, mode, payload, and timer source.

## Trusting Bootloader State

Use bootloader state carefully:

- Dump current clock, reset, interrupt, pinmux, and device status before changing it.
- Preserve known-good bootloader setup when reinitialization is risky.
- Make minimal changes and let lower gates decide.
- Do not generalize one device's rule to all devices. UART FIFO, interrupt enable, and baud setup are often safe to reinitialize; PHY and clock trees may not be.

Trusting reference material:

- Treat a traceable reference implementation (vendor trees, same-board projects, manual excerpts with provenance) as a contract input by default: register offsets, bitfields, timing, and usage semantics such as read/write order, unlock protocols, and write-without-read patterns.
- Align contracts with how the reference actually uses the hardware. Do not invent verification steps the reference never performs — for example, demanding readback on a write-driven register.
- Keep negative samples from the reference as review counterexamples; never merge foreign framework code wholesale into the project.
- Reference material provides expectations and explanations. Board-observed facts — register reads, PHY identity, link state — remain the evidence.

Board-adjudicated facts: when the board contradicts the manual (a trap value intermittently polluted, a mask window dropping events, a trigger bit that needs a companion register), record it as a platform constraint with its observing evidence, and code against the board, not the manual.

## Failure Triage

- No output: inspect image format, load address, entry, early console base/stride/width, and boot command.
- Fault after first output: inspect page tables, memory attributes, stack, relocation, and final address-space switch.
- Registers all zero: inspect MMIO mapping, clocks, reset, access width, and privilege.
- One interrupt only: inspect device status clear and EOI or complete.
- Interrupt storm: inspect cause-clear order, mask windows, and echo claims.
- Replug or link instability: verify the event path is still live (a latched level source can go permanently silent after one missed event), then gate state, then DMA liveness.
- Faults only on some cores: inspect cluster or core-type asymmetry before blaming the code. When the saved PC is correct but the fault address looks polluted, try eager population of executable pages and record the topology hazard.
- Workload hangs: step back to register, interrupt, queue, and wakeup gates.
- Performance oddity: compare against physical line rate or bus limit, not simulator numbers.

## Evidence Rules

- Record exact board, firmware, boot command, image name, and build feature set.
- Keep raw logs near the analysis.
- Label skipped gates with concrete blockers.
- Do not call a skipped shell, rootfs, or storage path a driver failure.
- Do not claim SMP validation until the workload actually ran on the relevant harts.
- Record board-adjudicated facts as durable platform constraints.
