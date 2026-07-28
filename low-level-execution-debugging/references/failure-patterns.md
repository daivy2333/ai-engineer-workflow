# Failure Patterns

Use the observed symptom to select the next evidence, not the fix.

## Contents

- Breakpoint or probe does not hit
- Unexpected PC or branch target
- Illegal instruction
- Trap or page fault at an unexplained address
- Backtrace or return path is wrong
- Artifact bytes differ from runtime bytes
- MMIO access fault or wrong register
- SMP-only divergence

## Breakpoint or probe does not hit

Check:

- Exact image and symbols.
- Symbol presence, size, and section.
- Inlining, dead-code elimination, and identical-code folding.
- Link address, load address, and relocation slide.
- Architecture and instruction mode.
- Breakpoint type and writable memory.
- Current CPU, hart, task, and address space.
- An earlier branch that bypasses the probe.

A missed software breakpoint does not prove the instruction was not executed.

## Unexpected PC or branch target

Capture:

- Instruction before the transition.
- Branch operands and computed target.
- Function pointer or dispatch-table entry.
- Return-address register and saved stack value.
- Trap entry and saved exception PC.
- Current privilege and address space.

Distinguish a wrong branch target from correct execution under the wrong symbols.

## Illegal instruction

Check:

- Runtime bytes at PC.
- Instruction alignment and length.
- Configured ISA and extensions.
- Current instruction mode.
- Executable page attributes.
- Code overwrite.
- Instruction-cache synchronization.
- Whether the saved exception PC points at or after the faulting instruction.

Disassemble the runtime bytes, not only the ELF.

## Trap or page fault at an unexplained address

Record:

- Trap cause and fault-address register.
- Saved PC and privilege.
- Faulting instruction.
- Effective memory address.
- Page-table root and translation.
- Page or region permissions and memory type.
- Whether the fault occurred during a context or address-space switch.

Do not treat the fault address and instruction address as interchangeable.

## Backtrace or return path is wrong

Check:

- ABI and return-address convention.
- Trap, interrupt, and context-switch frame layout.
- Stack bounds and alignment.
- Frame-pointer and unwind configuration.
- Optimization, inlining, and tail calls.
- Saved return address before and after each writer.
- Stack switching between boot, interrupt, kernel, and user contexts.

Use a watchpoint on the saved return address when hardware permits.

## Artifact bytes differ from runtime bytes

Prioritize:

1. Stale or wrong image.
2. Stale or wrong symbols.
3. Incorrect load or relocation address.
4. Wrong address-space translation.
5. Debugger stub memory semantics.
6. Runtime patching or overwrite.
7. Cache incoherence or missing instruction synchronization.

Do not continue source-level debugging until the difference is explained.

## MMIO access fault or wrong register

Check:

- Faulting load or store.
- Effective address calculation.
- Access width and alignment.
- Register stride and offset.
- Virtual mapping and physical base.
- Memory attributes and privilege.
- Device model on QEMU.
- Clock, reset, pinmux, and bus state on hardware.
- Read side effects.

Separate an address error from a device-state error.

## SMP-only divergence

Capture each CPU or hart:

- PC and stack.
- Current task and address space.
- Halt state.
- Relevant interrupt and lock state.
- Shared function pointers or return storage.

Single-core debugger success does not prove SMP correctness. Halting all cores can also hide the race.
