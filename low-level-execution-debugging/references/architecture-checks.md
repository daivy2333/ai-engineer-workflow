# Architecture Checks

Confirm the exact architecture and privilege model before using these registers. Platform firmware and debugger stubs can expose different names.

## RISC-V

Check:

- `pc`, `x1/ra`, `x2/sp`, and frame-pointer convention.
- `mepc`, `mcause`, `mtval`, `mstatus` for machine-mode traps.
- `sepc`, `scause`, `stval`, `sstatus` for supervisor-mode traps.
- `satp` and the active address-translation mode.
- `mtvec` or `stvec` mode and trap target.
- Enabled ISA extensions.

Compressed instructions can be 16 bits. Do not assume four-byte instruction alignment. After writing executable memory, confirm the required instruction-stream synchronization, such as `fence.i`.

`mepc` or `sepc` interpretation depends on the trap type. Verify whether it identifies the faulting or interrupted instruction before advancing it.

## x86-64

Check:

- `rip`, `rsp`, `rbp`, and calling convention.
- `cr2` for the linear address associated with a page fault.
- `cr3` and the active page-table hierarchy.
- Page-fault error code.
- IDT entry, privilege transition, and exception frame.
- Canonical-address rules.
- Per-CPU and thread-local bases when GS or FS participates.

Instructions have variable length. Start disassembly from a confirmed instruction boundary. A plausible decode from the middle of an instruction is not evidence.

## AArch64

Check:

- `pc`, `sp`, `x29`, and `x30`.
- Current exception level.
- `ELR_ELx`, `ESR_ELx`, `FAR_ELx`, and `SPSR_ELx`.
- `TTBRx_ELx`, `TCR_ELx`, and active translation regime.
- Exception vector entry.
- Pointer authentication or tagging when enabled.

A64 instructions are four bytes and aligned. After modifying executable memory, confirm data-cache cleaning and instruction-cache invalidation required by the platform.

## Arm and Thumb

Check:

- Current Arm or Thumb state.
- CPSR or xPSR state and exception mode.
- LR and exception-return encoding.
- Vector-table location.
- MPU or MMU configuration.

Symbol addresses may encode Thumb state in the low bit while the fetched instruction address is aligned. Normalize addresses according to the toolchain and debugger before comparing them.

## Cross-architecture checks

For every target, confirm:

- Instruction length and alignment.
- Endianness.
- Return-address convention.
- Trap frame and saved-PC semantics.
- Privilege level.
- Address-translation root.
- Cache maintenance for executable memory.
- Hardware breakpoint and watchpoint limits.
- Whether the debugger halts one execution context or all of them.
