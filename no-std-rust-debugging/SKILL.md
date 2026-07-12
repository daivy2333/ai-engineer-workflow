---
name: no-std-rust-debugging
description: Debug no_std Rust kernels, boot code, drivers, and embedded crates — anywhere std, process isolation, and normal OS diagnostics are absent. Use when investigating target-feature builds, Cargo feature gates, path dependencies, MMIO volatile access, atomics and locks, linker scripts, boot images, traps, page faults, SIGILL, ELF loader issues, or static user payloads. Make sure to invoke this skill whenever a no_std build, boot, trap, MMIO, or ELF-loader fault appears, even if the user only describes the symptom and does not name the underlying mechanism.
---

# no_std Rust Debugging

Use this skill to debug Rust kernel and embedded failures where std, process isolation, and normal OS diagnostics are absent.

## Build Triage

1. Pin the target.
   - Record toolchain, target triple, CPU features, platform feature set, linker script, and build profile.
   - Confirm whether the failing crate is built through the top-level workspace or directly by `--manifest-path`.

2. Inspect feature flow.
   - Use `cargo tree -e features` for the selected target when feature interactions matter.
   - Remember that build scripts may emit custom `cfg` values not visible as ordinary features.
   - Split hardware capability features from runtime mode features.

3. Protect dependency state.
   - Watch for `Cargo.lock` churn from path dependency checks.
   - Prefer exact versions for local kernel-adjacent crates when registry updates are unsafe.
   - Do not update unrelated dependencies while debugging a runtime fault.

## Runtime Fault Triage

- Load/store/AMO fault: inspect address translation, memory attributes, MMIO mapping, alignment, and access width.
- Instruction fault or SIGILL: disassemble the exact PC before blaming the compiler.
- Fault after page-table switch: inspect final page table flags, not only early boot mappings.
- Hang with no trap: inspect interrupt enable, wakeups, scheduler state, and forward-progress fallback.
- Panic in filesystem or loader: separate driver availability from rootfs policy.

## MMIO Rules

- Treat register stride and access width as separate facts.
- Use volatile reads and writes with the width required by the hardware.
- Do not use byte MMIO against a 32-bit-only APB register block.
- Read raw status registers before and after initialization.
- Keep unsafe blocks small and document the hardware invariant they rely on.

## Atomics and Locks

- Use Rust atomic orderings to express semantics, not architecture-specific folklore.
- Use `Relaxed` only for telemetry or state that does not drive control flow.
- Use `Release` and `Acquire` for published state.
- Use `AcqRel` for counters updated by RMW and read by completion logic.
- Use locks for multi-field consistency, especially cache plus MMIO writes.
- Verify what a lock means under the selected SMP feature set.

## ELF and Loader Rules

- Check ELF type, entry, program headers, relocations, interpreter, and required libraries.
- If the loader does not implement relocations, require `ET_EXEC` or add relocation support.
- For static payloads, verify `-no-pie`, no relocations, and expected ISA.
- For lazy mappings, compare against an eager mapping path before blaming device I/O.
- For user-visible argv/envp claims, require the user payload to print them or provide equivalent evidence.

## Evidence Checklist

- Exact command and feature set.
- First failing log line and trap frame.
- Disassembly around the PC for instruction faults.
- Register or page-table dump for memory faults.
- `readelf` or equivalent output for loader failures.
- A small regression command after the fix.
