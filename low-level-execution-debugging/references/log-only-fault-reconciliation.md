# Log-Only Fault Reconciliation

Reconcile a fault when the only evidence is a serial log line — typically a user-space process faulting under your own kernel or loader, on hardware with no debugger attachment. The address-ledger discipline from address-reconciliation.md still applies; here the runtime evidence is one printed line and the artifact is extracted from a filesystem image.

## Secure the artifacts

- Back up the delivered image before any diagnostic rebuild; a diagnostic build must never silently replace the delivery artifact.
- Rebuild for diagnostics with only the logging level changed — same command, same feature set, no product code edits — and restore the delivered build afterwards.
- Extract the faulting binaries from the filesystem image read-only with offline filesystem tools (no write mode); the source image never changes.
- Record the loader's base addresses from the kernel configuration: the program base and the dynamic interpreter base are different constants.

## Attribute the addresses

The fault line names pc, fault address, sp, and ra. Attribute each address independently; do not assume pc and ra belong to the same binary.

1. Verify the entry first: the kernel's "enter user space" address should equal the interpreter base plus the interpreter entry point (`readelf -h`); this proves which base applies.
2. For each address: pick the candidate binary, subtract its base, and check the result falls inside a mapped segment (`readelf -lW`); use section boundaries (`readelf -SW`) to name the region.
3. Classify pointer bugs with relocations (`readelf -rW`): relative entries, jump slots, and absolute entries each implicate a different table.

## Disassemble at the linked address

- Use a disassembler that supports the target architecture; the host's default objdump does not decode foreign ISAs — use a target-prefixed objdump or a cargo-provided equivalent.
- Start disassembly at the linked address; if the output looks decoded from mid-instruction, move the start earlier and realign.
- Strong evidence: the saved return address sits on a call site whose target equals the mapped pc. Stripped binaries are located by segment boundaries and `<nearest_symbol+offset>` annotations, with dynamic symbols (`--dyn-syms`) as a fallback.

## Trust checks on the trap frame

- Canonical-address check first (for example SV39: address bits above the VA width must all equal the sign bit). A non-canonical fault address indicates a corrupted or synthesized value.
- For an instruction page fault, the saved PC and the fault address should name the same instruction. A mismatch means the fault-address register is unreliable on this core: distrust the fault address, keep the saved PC, and record the core behavior as a platform constraint.
- A fault address that repeats the saved PC's low bits with garbage in the high bits is a hallmark of intermittent delivery corruption on some cores — reconcile bytes before symbols before blaming memory management.

## Failure handling

- No fault line in the log: the build's logging may be compiled out — check for the "logging enabled" banner; some exit paths bypass the logger, so check the process-exit lines too.
- Symbols do not resolve: stripped binary; fall back to segment boundaries, relative symbols, and dynamic symbols.
- Everything attributes cleanly but the story does not close: stop, keep the log and binary copies, and hand back to planning. Do not iterate blind reconstructions.
