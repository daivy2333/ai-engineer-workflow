---
name: qemu-kernel-debugging
description: Debug, validate, or benchmark kernels and drivers under QEMU. Use when working with emulator boot failures, QEMU device models, MMIO layout, IRQ behavior, rootfs test payloads, GDB traces, regression gates, or when deciding which QEMU results can and cannot count as hardware evidence. Make sure to invoke this skill whenever a kernel or driver is being developed or tested under an emulator, virtual machine, or simulation environment, even if the user does not explicitly say 'QEMU' but describes a virtual environment that resembles one.
---

# QEMU Kernel Debugging

Use QEMU as a fast development gate. Treat it as a functional and regression tool, not as proof of physical timing.

## Workflow

1. Establish the emulator contract.
   - Record machine type, CPU count, memory, device base, IRQ, register stride, access width, bus type, rootfs image, and boot arguments.
   - Check the device model. QEMU devices may differ from the target board even when names look similar.

2. Get a minimal boot witness.
   - Capture early serial output.
   - Print platform name, memory map, MMIO map, IRQ setup, and rootfs source.
   - Keep a failing boot log before changing code.

3. Reduce the failing layer.
   - Boot failure: inspect image, linker base, entry, page table, and traps.
   - MMIO failure: inspect base, stride, width, mapping, and config.
   - IRQ failure: inspect enable path, claim path, handler entry, status clear, and EOI.
   - User payload failure: inspect ELF type, loader path, argv/envp, stdio, page faults, and exit status.

4. Validate by gates.
   - Run compile checks first.
   - Run QEMU boot next.
   - Run shell or command smoke only after boot is stable.
   - Run benchmark last.
   - Keep every command and feature set in the evidence.

## What QEMU Can Prove

- Build and link correctness for the selected target.
- Basic boot path and early serial path.
- Driver API integration and most file/device operations.
- Interrupt handler plumbing when the QEMU device model matches the intended behavior.
- Rootfs and user payload launch paths.
- Regression against previous QEMU logs.

## What QEMU Cannot Prove

- Physical UART line rate.
- True FIFO timing unless the device model implements it.
- Board clock, reset, pinmux, cache, and memory-attribute behavior.
- SMP memory ordering when QEMU runs one hart.
- DMA coherency on real interconnects.
- Bootloader handoff quirks on a real board.

## Debugging Rules

- Do not blame page tables before checking MMIO base, stride, width, and platform config.
- Do not compare QEMU throughput directly with true-board throughput.
- Do not treat a QEMU pass as proof of SMP unless multiple harts are configured and exercised.
- Do not hide known warnings inside a successful gate; record whether they are pre-existing.
- Prefer deterministic test payloads over interactive shell checks when validating regressions.

## Benchmark Rules

- Label every result as QEMU or hardware.
- Separate ring-buffer speed, syscall path latency, and physical device throughput.
- For UART, QEMU `tcdrain` or LSR polling may not model line delay.
- Use QEMU benchmark for regressions: hang, short write, nonblocking behavior, ordering, and gross latency changes.
- Use hardware benchmark for line-rate claims.
