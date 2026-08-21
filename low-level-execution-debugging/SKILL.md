---
name: low-level-execution-debugging
description: Debug low-level runtime execution by reconciling source intent, ELF and linker layout, loaded memory, runtime PC, symbols, disassembly, address translation, and MMIO addresses. Use for kernels, bootloaders, firmware, and embedded targets when breakpoints or probes do not hit, execution reaches an unexpected address, traps or illegal instructions occur, stack traces look wrong, symbols do not match memory, link and load addresses differ, or GDB, LLDB, QEMU, JTAG, or OpenOCD evidence is needed.
---

# Low-Level Execution Debugging

Use this skill to prove which instructions a CPU executed and how their runtime addresses relate to the exact binary. Keep the process language-, debugger-, architecture-, and target-agnostic.

## References

- Always read [references/address-reconciliation.md](references/address-reconciliation.md).
- For a live debugger, QEMU monitor, or hardware probe, read [references/debugger-evidence.md](references/debugger-evidence.md).
- For symptom-specific branches, read [references/failure-patterns.md](references/failure-patterns.md).
- For RISC-V, x86-64, AArch64, or Arm details, read [references/architecture-checks.md](references/architecture-checks.md).

## Workflow

1. Freeze the target contract.
   - Record the exact ELF, image, debug symbols, linker script, map file, and build command.
   - Record target triple, ISA features, endianness, optimization, relocation mode, and debug-info mode.
   - Record the loader, load address, entry point, debugger, transport, target, CPU count, and current CPU or hart.
   - Use an existing Build ID when the artifact already provides one. Do not generate or persist a hash solely for debugging or evidence.
   - Do not trust a debugger session until its symbols match the running image.

2. Build an address ledger.
   - Distinguish source location, symbol address, VMA, LMA, file offset, runtime virtual address, physical address, relocation slide, and MMIO address.
   - State which address space every reported address belongs to.
   - Derive conversions from program headers, mappings, page tables, relocation state, and loader behavior.
   - Do not infer physical addresses from virtual addresses without translation evidence.

3. Establish static evidence.
   - Inspect ELF type, entry, program headers, sections, symbols, relocations, and instruction encoding.
   - Disassemble the exact artifact around the expected symbol and observed PC.
   - Record symbol start, symbol size, instruction bytes, and offsets.
   - Prefer instruction-level evidence over source-line assumptions.

4. Capture the runtime witness.
   - Halt at the earliest safe point that preserves the failure.
   - Record PC, SP, frame or return registers, status, privilege, trap cause, fault address, CPU or hart, and task when available.
   - Read raw bytes and decoded instructions around PC.
   - Record mappings, page-table root, loaded sections, and relocation slide when relevant.
   - Capture all CPUs or harts when another execution context may own the failure.

5. Reconcile bytes before symbols.
   - Compare runtime bytes at PC with bytes from the exact artifact.
   - If they differ, investigate stale images, wrong symbols, load offsets, relocation, address translation, overwrite, cache maintenance, and debugger address-space selection.
   - Do not trust source stepping, symbols, or backtraces until the bytes can be explained.

6. Reconstruct control flow.
   - Start from the first confirmed instruction.
   - Place breakpoints at branch boundaries, trap entry, dispatch, and return sites.
   - Use instruction stepping when source stepping hides inlining, tail calls, or instruction-mode changes.
   - Use watchpoints for return addresses, function pointers, or corrupted state.
   - Record each confirmed edge as source address, instruction, target address, and resulting state.

7. Minimize observer effects.
   - Prefer static inspection and read-only capture before breakpoints or instrumentation.
   - Prefer hardware breakpoints when software breakpoints would modify ROM, shared code, or timing-sensitive paths.
   - Record debugger halts, breakpoint type, watchpoint limits, and probe-induced timing changes.
   - Propose source probes only after non-mutating evidence is insufficient.
   - Modify source or flash hardware only when the user requests that action.

8. Report the proven boundary.
   - State the expected address, actual address, address spaces, artifact identity, byte comparison, and control-flow evidence.
   - Separate facts, deductions, and unresolved hypotheses.
   - Name the first edge or translation that lacks evidence.
   - Give the next probe that can distinguish the remaining hypotheses.

## Environment Rules

- QEMU proves behavior of the selected machine and device models, not physical timing or board wiring.
- JTAG and OpenOCD prove the attached target state, but halting may change timing and peripheral behavior.
- GDB Remote Protocol does not guarantee that memory, registers, and breakpoints have identical semantics across stubs.
- Optimized code may inline, merge, reorder, or remove source constructs.
- A valid symbol name does not prove that the running bytes came from that symbol file.
- A plausible backtrace does not prove that unwind data or stack frames are valid.
- MMIO stride, access width, effective address, mapping, and memory attributes are separate facts.

## Evidence Checklist

- Exact artifact, existing Build ID when available, and build configuration.
- Target, architecture, CPU or hart, privilege, and debugger transport.
- Link address, load address, runtime address, and translation method.
- Symbol and section evidence.
- Runtime PC, registers, raw bytes, and disassembly.
- Trap or fault registers when present.
- Confirmed control-flow edges.
- Breakpoint, watchpoint, trace, or probe side effects.
- Commands, outputs, exit status, and remaining uncertainty.

## Anti-Patterns

- Loading convenient symbols instead of symbols from the running image.
- Converting an address with `addr2line` before identifying its address space and relocation.
- Debugging only at source-line level.
- Treating a breakpoint miss as proof that code did not execute.
- Trusting a backtrace after trap entry, stack corruption, or context switch without checking frame rules.
- Reading MMIO through a debugger without accounting for side effects.
- Flashing, resetting, or patching the target before preserving the failing witness.
- Applying a fix before the first unexplained execution edge is located.
