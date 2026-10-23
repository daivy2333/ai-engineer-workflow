# Driver Host Fixtures

How to test real driver and queue logic on the host, before any guest or board run. The goal is to drive the production adapter or service object, not a copy of its algorithm.

## Minimal OS seams

- Keep the driver's OS dependencies behind two or three minimal traits (spawn/block, waker set, time). Every trait must have a live caller; delete the unused ones.
- With small seams, production driver and queue code compiles and runs inside host test binaries, and the same assertions cover the shipped code path.

## Driving the real adapter

- Implement a local fake transport or bus: identity DMA mapping, a config space with the register layout the driver expects, queue-setup recording of device areas.
- Simulate device-side completion by writing the completion ring in the same order the driver consumes it; a completion-order mismatch produces false ownership findings.
- Test infrastructure inside a dependency is often compile-gated and invisible to downstream crates. Do not try to reuse gated fakes; use a non-gated accessor marked test-only, or a seam local to the adapter.
- Some invariants cannot be triggered through the real path (a well-formed queue never returns certain tokens). Inject a forced token through a test-only field to prove the post-accept invariant: the ledger stays intact and returns a stable error, never panics.
- Assert the real ledger fields from a test module in the same crate; for error types that only derive Debug, use `matches!`, not `assert_eq!`.

## RED to GREEN

- Write the assertion against current behavior first, watch it fail for the expected reason, then implement. A fixture test that passes on the first run proves nothing about the change.

## Determinism discipline

- Isolate tests from process-global state: a shared registry used by parallel tests turns failures intermittent and unattributable.
- Deterministic replays: single-threaded runs repeated ×100, and known-unaffected subsets run in parallel ×100. A failure that always passes on isolated rerun is nondeterminism, not a product regression — attribute before counting (see the host-test-debugging skill).
- Known flakes are tracked separately and never silently excluded from a run.
