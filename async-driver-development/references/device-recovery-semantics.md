# Device Recovery Semantics

Rules for drivers that must survive device reset, link flap, hot removal, or transport-level recovery. Apply to network, block, and any descriptor engine with DMA state.

## Epoch and generation layering

- Every recovery boundary increments a generation on each layer that outlives it: a queue epoch (per hardware-queue rebuild), a link or transport epoch (per link or reset event), and a waiter or session epoch (per waiter-visible object).
- Objects, tokens, and tickets carry the epoch they were born in. A completion or handle from an older epoch is discarded, never re-attributed.
- New submissions are born in the current epoch. The entry point rejects work addressed to a terminated epoch with a terminal error instead of silently accepting it.

## Reset and rebuild

- Controlled reset sequence: stop the dataplane, block new submissions, software-reset the device, rebuild the queues in place (fresh zeroed slots and rings), re-arm, then verify with a bounded functional exchange before reopening to users.
- Rebuild in place: the same backing memory is re-initialized rather than reallocated, so capacity and layout contracts survive the reset.
- Late completions from the pre-reset ring are dropped by epoch check; the ledger never reclaims a slot the device no longer owns.
- Link events arriving during a reset are queued as recovery input; they are not processed against a half-rebuilt queue.

## DMA quiesce before release

- Register readback is not proof that a device stopped mastering the bus. A clean status word after reset does not bound in-flight DMA.
- Release DMA backing (buffers, rings, arena pages) only after proven quiesce: completion queues drained plus a device-specific stop condition evidenced the way the platform defines it.
- When quiesce cannot be proven, keep the faulted owner, retain the backing, and refuse new submissions. Retaining backing until an external reset is an acceptable terminal state.
- Cache maintenance (publish before submit, reclaim before reuse) is part of the same ownership contract; a recovery path that skips it corrupts the first post-reset exchange.

## Link flap and event paths

- Arm interrupt paths per event source with the correct edge or level semantics; latched level sources need an ack-by-read consumer on the owner path.
- After a flap or replug, verify the event path is still live before trusting the dataplane: on a latched level source, one missed event can silence it permanently if nothing polls.
- A recovery matrix covers at least: unplug while idle, unplug under load, reset mid-flap, replug after reset, and duplicate events. Each case asserts terminal publication to waiters plus a fresh functional exchange.

## Terminal publication

- Waiters blocked on an object that is being reset receive a terminal error at the recovery boundary; they must not hang waiting on an epoch that will never complete.
- A flush pending across a reset aborts; the abort reaches the requester, it is not dropped.

## Measurement discipline

- Before declaring quiescence, run a settle phase: all activity counters stay flat for a fixed window, then freeze and read them as evidence of quiescence. A protocol close can trail visible completion by several packets; measuring too early reports a false active state.
- Scope recovery claims by evidence class — emulator, simulator, real board.
- A repair cycle that does not shrink the gap means the recovery model or design assumption is wrong — re-examine the model instead of retrying the same fix.
