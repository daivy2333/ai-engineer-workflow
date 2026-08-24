---
name: qemu-kernel-debugging
description: Debug, validate, or benchmark kernels and drivers under QEMU. Use when working with emulator boot failures, QEMU device models, MMIO layout, IRQ behavior, rootfs test payloads, GDB traces, regression tests, or when judging which QEMU results can support hardware claims. Make sure to invoke this skill whenever a kernel or driver is being developed or tested under an emulator, virtual machine, or simulation environment, even if the user does not explicitly say 'QEMU' but describes a virtual environment that resembles one.
---

# QEMU Kernel Debugging

Use QEMU to diagnose functional behavior and regressions. Do not treat it as proof of physical timing.

## Technical Triage

1. Identify the emulated machine, CPU count, memory, boot inputs, console, and target device model. For device failures, also check MMIO base, IRQ, register stride, access width, and bus type. A QEMU device may differ from the target board even when names match.

2. Observe the earliest reliable boot output. Use platform identity, memory and MMIO maps, IRQ setup, and rootfs source to locate the first failing layer.

3. Reduce the failing layer.
   - Boot failure: inspect image, linker base, entry, page table, and traps.
   - MMIO failure: inspect base, stride, width, mapping, and config.
   - IRQ failure: inspect enable path, claim path, handler entry, status clear, and EOI.
   - User payload failure: inspect ELF type, loader path, argv/envp, stdio, page faults, and exit status.

4. Check artifact compatibility before attributing the failure to QEMU or the driver. Kernel, DTB, modules, initramfs, and rootfs must match the intended architecture and build. For module failures, compare the running kernel release with the installed module tree; stale or mixed outputs can mimic driver faults.

## Specialized References

- For Linux direct-kernel boot, firmware handoff stages, console routing, or boot-path failures, read [references/linux-boot-paths.md](references/linux-boot-paths.md).
- For raw, qcow2, pflash, partition, fixed-offset, backing-chain, or guest-mutation problems, read [references/image-layout-and-mutation.md](references/image-layout-and-mutation.md).

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
- Distinguish pre-existing warnings from the failure being diagnosed; a successful process exit does not make warnings irrelevant.
- Prefer deterministic test payloads over interactive shell checks when validating regressions.

## Benchmark Rules

- Label every result as QEMU or hardware.
- Separate ring-buffer speed, syscall path latency, and physical device throughput.
- For UART, QEMU `tcdrain` or LSR polling may not model line delay.
- Use QEMU benchmark for regressions: hang, short write, nonblocking behavior, ordering, and gross latency changes.
- Use hardware benchmark for line-rate claims.
