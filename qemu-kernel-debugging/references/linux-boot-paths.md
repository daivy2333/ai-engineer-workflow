# Linux Boot Paths under QEMU

Direct-kernel and firmware boot traverse different code, consume different inputs, and expose different failure boundaries.

## Direct-kernel boot

With `-kernel`, QEMU loads the kernel without traversing firmware or a bootloader. Depending on the architecture and machine, the path may also use:

- `-dtb` or a QEMU-generated FDT.
- `-initrd` for an initramfs.
- `-append` for `console=`, `root=`, `rdinit=`, `init=`, early-console settings, and other kernel arguments.

The kernel image type must match the target architecture and QEMU machine. When direct boot fails, compare the machine options, image type, command line, console, DTB, and initrd or block rootfs before suspecting the device model.

## Firmware boot

Firmware boot may traverse ROM, BIOS, pflash, SPL, TPL, TF-A, EDK2, OpenSBI, U-Boot, vendor firmware, or boot media before reaching the kernel. Useful failure boundaries include:

- Reset vector or ROM entry.
- First firmware console output.
- SPL, TPL, or equivalent early loader.
- Trusted firmware or monitor handoff.
- Bootloader prompt or autoboot path.
- Boot-media access.
- Kernel entry.
- Linux console, init, rootfs, or shell.

Firmware, bootloader, kernel, DTB, rootfs, and boot media are separate inputs even when a final image combines them. Pflash, firmware variables, and writable boot media can change between runs. If Linux and firmware use different consoles, identify the QEMU chardev carrying each stage.

When firmware boot fails, locate the last reached boundary before changing source. A firmware banner does not prove kernel entry, and a kernel banner does not prove init or rootfs success.

## Console and process behavior

`-nographic` commonly routes the guest console through the terminal, but explicit chardev and serial options can redirect or multiplex output.

A file-backed chardev may flush its final marker only when QEMU shuts down. Classify the run from the finalized output after process exit, not only from a live tail:

- Exit code zero without the required guest marker is inconclusive.
- A timeout without a terminal marker is inconclusive rather than proof of guest failure.
- A guest failure marker remains a failure even if the QEMU process exits successfully.

## Focused probes

- `-S -s` starts with guest CPUs stopped and exposes the default GDB stub.
- QEMU log flags and trace events can isolate device access, interrupts, translation, or exceptions.
- Instruction logging is expensive; restrict it to the smallest useful execution window when possible.
