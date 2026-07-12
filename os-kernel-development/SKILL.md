---
name: os-kernel-development
description: Plan, implement, review, or debug operating-system kernel work. Use when working on kernel subsystems such as boot, memory management, scheduler, syscall, VFS, drivers, interrupt handling, platform support, or user-process loading, or any cross-subsystem change that needs layered gates, minimal repros, and regression evidence. Make sure to invoke this skill whenever the task touches a kernel subsystem, even if the user does not name the subsystem directly and only describes an unstable kernel, a panic, a fault, or a driver that misbehaves.
---

# OS Kernel Development

Use this skill for kernel work where a bug or feature crosses boot, memory, tasks, filesystems, drivers, interrupts, or user space. Keep the work layered and measurable.

## Workflow

1. Locate the layer.
   - Identify whether the task belongs to boot, platform, memory, tasking, interrupt, driver, VFS, syscall, user loader, or workload.
   - Do not debug a higher layer until the lower layer has a fresh witness.
   - Record the first layer where evidence stops.

2. Build a current-state witness.
   - Read the relevant design docs, specs, or local architecture notes.
   - Inspect the actual symbols and callers before editing.
   - Record the commands that currently pass or fail.
   - Preserve raw logs for boot, trap, benchmark, and true-board evidence.

3. Make the smallest coherent change.
   - Prefer one ownership fix, one contract change, or one gate per patch.
   - Keep platform facts in platform descriptors or equivalent modules.
   - Keep policy out of low-level mechanisms unless the project already does so.
   - Do not mix bring-up, optimization, cleanup, and user-visible behavior in one change.

4. Validate by dependency order.
   - Build check.
   - Boot or unit witness.
   - Subsystem smoke.
   - Cross-subsystem integration.
   - Workload or benchmark.
   - Hardware or SMP proof if the claim depends on hardware or SMP.

5. Update persistent knowledge.
   - Record new decisions as architecture notes.
   - Record new traps, commands, and platform facts as learned notes.
   - Archive or tombstone stale plans after the active state moves elsewhere.

## Layer Gates

- Boot: image format, entry, linker base, stack, early output.
- Platform: memory map, MMIO map, hart topology, timer, interrupt controller.
- Memory: page-table flags, address-space switch, fault type, mapping ownership.
- Interrupts: enable, claim, handler, device status clear, EOI or complete.
- Scheduler: task creation, wakeup, blocking, preemption, SMP assumptions.
- Driver: register access, IRQ, buffers, completion, user-facing device node.
- VFS/syscall: open, read, write, poll, ioctl, error propagation, short I/O.
- Loader: ELF type, mappings, argv/envp, stdio, page faults, exit status.
- Workload: deterministic payload, mode label, raw output, exit code.

## Debugging Rules

- Reduce the failure before adding features.
- Check constants, feature gates, and platform selection before suspecting deep logic.
- Treat QEMU, simulator, and real board as separate evidence classes.
- Treat single-hart success as insufficient for SMP claims.
- Treat shell, rootfs, and storage as optional gates unless the current task is about them.
- Prefer explicit blockers over vague failure labels.

## Review Checklist

- Does the change respect subsystem ownership?
- Does it preserve early debug output or another recovery path?
- Does it introduce hidden platform assumptions?
- Does it rely on stale line numbers or old branch state?
- Does the validation match the claim?
- Are skipped gates named with concrete blockers?

## Anti-Patterns

- Do not apply multiple historical fixes at once without per-step gates.
- Do not hide a lower-layer failure behind a benchmark or shell failure.
- Do not make a user workload the first proof of a driver or platform path.
- Do not change external or registry crates when a local adapter can contain the fix.
- Do not claim performance without stating environment, method, payload, and timer source.
