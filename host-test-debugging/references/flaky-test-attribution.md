# Flaky Test Attribution

Decide whether an intermittent host-test failure is a product regression, a pre-existing race, or a known flake — before counting it. Built for kernel-adjacent suites where process-global state (static registries, global sets) is shared across parallel tests.

## Signals at first sight

| Signal | Meaning |
|---|---|
| Fails sometimes, always passes on isolated rerun | Nondeterminism; not yet a product regression |
| Panic inside third-party data structures (stale-handle assertions, internal consistency checks) | The failure surface is shared state, not the tested logic |
| Allocator corruption reports, SIGSEGV, SIGABRT | Real memory unsafety underneath, never mere assertion noise |
| A known flake reproducing again | Track it under its recorded policy; do not re-litigate it per run |

## Deterministic witnesses

- Single-threaded reruns of the failing subset, repeated ×100.
- A known-unaffected subset run in parallel, repeated ×100, proves the harness itself is not the flake.
- These runs are the trusted baseline: the flaky full suite cannot adjudicate itself, and a single full-suite pass proves nothing.

## Dimension isolation

- Per-test loops (×40 typical) over candidate tests rank failure rates; a 0-fail test next to a 40%-fail test both touching the same registry points at the shared ingredient.
- Compare subsets that share the suspected global against subsets that do not: a large rate gap implicates the global.
- The usual culprit is process-global state with no per-test isolation. The fix direction — per-test wrappers, serialized access, or eliminating handle-reuse windows — belongs to a separately planned change, not to the flaky investigation.

## Control groups

- Byte-revert the current product diff (stash-based, per the kernel-development skill's build and regression triage reference) and rerun the same subsets on the old code.
- Statistically indistinguishable failure rates across old and new code mean the race predates the diff. Record the numbers, not just the conclusion.
- A control group bounds blame; it never proves the current code safe for the dimensions it did not test.

## Recording

- The attribution entry keeps: the timeline, the deterministic replay results, the per-subset failure rates, the control-group numbers, and the conclusion labeled Confirmed, Inferred, or Unconfirmed.
- A race whose exact unsafe point is not found is recorded with its mechanism inferred and its boundary unconfirmed; do not promote an inference to a confirmed root cause.
- Vulnerable working-tree state (a stash pop that conflicted mid-investigation) is recovered with the index-surgery sequence in the kernel-development skill's build and regression triage reference.
