# Debugger Evidence

Select commands by capability. GDB names below are examples, not workflow requirements.

## Contents

- Session setup
- Runtime capture
- Control-flow probes
- QEMU
- JTAG and OpenOCD
- Observer effects

## Session setup

Confirm:

- Architecture and byte order.
- Symbol file and loaded section addresses.
- Remote target and reset state.
- Current CPU, hart, process, address space, and privilege.
- Whether the target was halted before attachment.
- Whether the stub exposes virtual or physical memory.

Useful GDB capabilities:

```text
file <elf>
symbol-file <elf>
add-symbol-file <elf> <runtime-text-address>
target remote <endpoint>
info files
maintenance info sections
show architecture
show endian
```

Do not issue `load`, flash, reset, or restore commands unless the user requested target mutation.

## Runtime capture

Capture registers and memory before stepping:

```text
info registers
x/16xb <pc>
x/10i <pc>
disassemble /r <start>, <end>
info symbol <address>
info line *<address>
bt
thread apply all bt
```

Use raw bytes with disassembly. A decoded instruction without bytes can hide wrong architecture, mode, or address-space selection.

For multiple CPUs or harts:

- Enumerate all execution contexts.
- Record which context owns the current breakpoint.
- Capture PC and stack for each context.
- Avoid assuming the boot CPU executes later work.

## Control-flow probes

Choose the least disruptive capability:

1. Static disassembly.
2. Halt and read state.
3. Hardware breakpoint.
4. Software breakpoint.
5. Hardware watchpoint.
6. Tracepoint or branch trace.
7. Temporary source instrumentation.

Useful GDB operations:

```text
hbreak *<address>
break *<address>
watch <expression>
rwatch <expression>
awatch <expression>
stepi
nexti
continue
```

Record breakpoint type and whether it changed target memory. Hardware resources and watchpoint widths vary by target.

## QEMU

A common GDB Remote setup uses a halted guest and a GDB endpoint:

```text
qemu-system-<arch> ... -S -gdb tcp::<port>
```

`-s -S` is a common shorthand for a default endpoint. Verify the actual command and port.

Use QEMU monitor capabilities when available to inspect:

- Registers.
- Memory tree and device mappings.
- Virtual or physical memory.
- CPUs.
- Interrupt state.

Monitor commands vary by QEMU version, machine, and accelerator. Record the exact invocation and machine model.

## JTAG and OpenOCD

Record:

- Probe and adapter.
- Target configuration.
- Adapter speed.
- Reset mode.
- Halt reason.
- Selected core.
- Breakpoint and watchpoint resources.
- Memory access mode.

Safe initial capabilities include target enumeration, halt-state inspection, register reads, and memory reads. Treat reset, flash, erase, register writes, and memory writes as target mutations.

On real hardware:

- Halting one core may not halt peripherals or other cores.
- Reading some MMIO registers can clear or advance device state.
- Watchdogs may continue while the CPU is halted.
- Caches can make debugger memory views differ from CPU fetches.

## Observer effects

Record when the debugger:

- Inserts a software trap instruction.
- Stops all CPUs or only one.
- Changes interrupt timing.
- Prevents watchdog servicing.
- Reads a destructive MMIO register.
- Uses semihosting.
- Flushes or bypasses caches.

If the failure disappears under the debugger, reduce the probe and compare the changed timing or shared state.
