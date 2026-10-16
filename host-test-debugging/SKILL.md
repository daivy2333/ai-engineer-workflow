---
name: host-test-debugging
description: Debug host-side Rust test binaries — kernel, driver, and no_std-adjacent code tested on the host — when a deterministic test failure contradicts static code reading, when you need real state values from inside a running test, when parallel test runs fail intermittently, or when you must decide whether a flaky failure is a product regression or pre-existing infrastructure. Covers debugger batch forensics (symbol discovery, phase selection, state extraction, event reconstruction) and nondeterministic-failure attribution (deterministic replays, subset isolation, control groups). Make sure to invoke this skill whenever a cargo test fails or flakes and reading code alone cannot reconcile the evidence, even if the user only reports the failing assertion.
---

# Host Test Debugging

Use this skill when host tests for kernel-adjacent code fail and the evidence does not close by reading code. Two modes:

- Deterministic failure — the test fails the same way every run: take real state values with a debugger. Read [references/gdb-batch-forensics.md](references/gdb-batch-forensics.md).
- Intermittent failure — the failure comes and goes across runs: attribute it before counting it. Read [references/flaky-test-attribution.md](references/flaky-test-attribution.md).

Not for use on: live targets under a remote debugger or hardware probe (use the low-level execution debugging skill), emulator guests (use the QEMU skill), or failures already localized by their own diagnostics.

## Shared preconditions

- Reproduce natively once and record the panic line and any printed snapshot verbatim; the forensics goal is always to explain that snapshot.
- The test binary must be a debug build with debug assertions active; check the package for profile overrides before reasoning from a silent debug_assert.
- Work from the actual test binary on disk; names in the binary may differ from source names.

## Deterministic failure: state forensics

Full command recipes and the dead-end catalog live in the reference. The workflow:

1. Locate the binary and its real symbols: `nm -C` on the test binary. A crate's name in the binary can differ from its source name, and breakpoint names must use the full demangled form.
2. Run under a batch debugger: test arguments go through `--args`; each batch run replays the whole test, so merge print commands into one session.
3. Select the failing phase: skip the first N-1 hits of a breakpoint (`ignore`) to land directly in the failing iteration, then confirm the call site with a short backtrace before trusting any value.
4. Add deep breakpoints two-stage: stop on the outer phase first, then set the inner breakpoint so it only catches events inside that phase.
5. Extract values in order of trust: typed field prints at body-line breakpoints; one-shot whole-slice prints; raw memory dumps only when cross-checked against typed prints (compiler layout reordering makes raw field order unreliable).
6. Reconstruct what happened between two stops: dump the same fields at both stops; the delta is the event history between them.
7. Reconcile: the values must both explain the failure and contradict the earlier static reading in a specific, nameable way. Three rounds without reconciliation — stop, re-read the code, and choose a different phase.

## Intermittent failure: attribution

The full discipline lives in the reference. The workflow:

1. Signal check: an intermittent failure that always passes on isolated rerun is nondeterminism, not a product regression. Panics inside third-party data structures and allocator or signal crashes indicate real memory unsafety underneath, not assertion noise.
2. Build deterministic witnesses: single-threaded runs repeated ×100 and known-unaffected subsets run in parallel ×100. These runs adjudicate; the flaky full suite cannot adjudicate itself.
3. Isolate by dimension: per-test loops rank failure rates; comparing subsets that share a suspected process-global against subsets that do not implicates the shared state.
4. Run control groups before blaming the current change: byte-revert the product diff and rerun; statistically indistinguishable failure rates mean the race predates the change.
5. Record the attribution with its data. A failure counts only in the bucket the data supports: product regression, pre-existing race, or known flake.

## Evidence rules

- Keep the reproduction command, the original snapshot, the debugger script essentials, and the decisive values that reconciled them.
- A forensics session that does not close records what was excluded, not just what was tried.
- Attribute before counting: a failure's bucket must have data behind it.

## Anti-Patterns

- Do not trust source names in the binary; look them up with `nm -C`.
- Do not debug at source-line level when inlining or layout hides the truth; stop at instruction or body-line breakpoints and print fields.
- Do not print collections element by element; print the whole slice in one expression.
- Do not set watchpoints before the target memory is mapped.
- Do not rerun a flaky suite until it passes and call it green; deterministic witnesses and attribution are the path to a defensible claim.
- Do not treat a matching control group as proof of safety; it bounds the blame, it does not fix the race.
