# Queue Service Layers

Execution-layer contracts for drivers whose ownership unit is a packet buffer or a request descriptor: network MACs, block and storage controllers, and similar engines. Byte-stream copier drivers stay in the SKILL.md workflow.

## Layer contract

| Layer | May do | Must not do | Owns |
|---|---|---|---|
| Hard IRQ | read cause, ack/mask, snapshot minimal counters, wake the queue owner, apply a bounded storm budget | move packets, allocate, lock shared state, run the protocol stack | IRQ shadow state |
| Queue task | reap/refill/reclaim descriptors, DMA sync, publish/consume slots, enforce budget, wake the runner on readiness change | spin unbounded on one queue, hold spin locks across awaits | hardware queue and slot ledger |
| Stack or service runner | poll protocol or service state, run timers, wake waiters | touch device IRQ or reset registers directly | protocol and service state |
| Caller, syscall, or read path | copy, block or nonblock, poll/select | hold descriptors or queue state directly | request lifetime |

A wake that skips the queue task (IRQ waking the runner or a socket directly) leaves descriptors unowned and stalls the dataplane under load.

## Slot and descriptor ledger

- Fixed capacity per direction. A slot cycles through owned-by-device, completed-unreclaimed, and owned-by-stack states; the ledger is the single completion authority.
- Publish, reap, refill, wrap: publish prepared buffers, reap completions, refill only freed slots, wrap with modular indices. Validate ring indices and lengths against capacity before trusting device-written metadata.
- Full does not overwrite: a full RX or TX side applies typed backpressure (drop-class, retry-class, or wait-class) and never clobbers live slots.
- Reclaim is single-owner and single-pass. Double reclaim and missed reclaim are the two ledger invariants to test explicitly.
- Errors classify per slot (bad frame, invalid metadata, timeout) and never abort the ledger; capacity and conservation counts must stay explicable on every error path.

## Budget and progress

- Every queue-task round has a bounded budget (descriptors, bytes, or iterations). On exhaustion, reschedule and let other tasks run; never run an unbounded drain loop inside one wakeup.
- One owner per hardware queue keeps the ledger race-free; a second queue gets its own task, never a shared loop.

## Backpressure, flush, and completion

- Backpressure states are typed and observable: each direction exposes occupancy, and a waiter can distinguish "queue full, retry" from "device faulted, fail".
- Flush is ticketed: request a flush boundary, release queued work, confirm the boundary. A flush pending across a reset aborts, and its requester gets the abort as a terminal result.
- Accepted, device-completed, and reclaimed are distinct states.

## Transport-neutral queue contract

- Queue ownership, backpressure, and completion semantics are defined against the queue interface, not the bus. Transport adapters live at probe, IRQ routing, and DMA/cache boundaries only.
- Device IRQ control seam: read_cause, ack, mask, rearm, snapshot counters, wake the owner. Nothing else runs in interrupt context.
- On event-suppressing transports (used-event/avail-event notification), rearm is separate from unmask and requires its own recheck; suppressed notifications behave like level-triggered readiness — poll once after rearm before sleeping.
- One handler per device IRQ beats a multiplexed global hook: a handler bound to one IRQ cannot eat or ack another device's events. Registration results are checked at init.

## Cause and mask semantics

- Write-to-clear or clear-on-read cause registers: snapshot before ack; accumulate several causes from one physical IRQ; re-check the source after unmask because the mask window can drop edge or MSI events.
- Echo or null-cause claims (sources that report an empty cause per physical event) are excluded by a cause classifier, not by acking blindly.
- Level-type sources that only deassert after a read: arm clears pending first, and the owner's read path consumes the latch. There is no fallback polling unless the event path is proven lossy.
- Masking stops storms; it does not preserve events. Any correctness argument that requires "no event is lost while masked" is wrong.

## Failure modes

| Failure | Signature | Rule |
|---|---|---|
| Lost wakeup | data available, future Pending forever | register-recheck around every sleep; rearm gets its own recheck |
| Wake skips queue task | counters move, descriptors never reap | wake order IRQ → queue task → runner |
| Self-wake storm | runner re-arms every packet while its gate is closed | the wake condition must include the gate; throttle or block re-arm when unsatisfied |
| IRQ storm | cause never cleared, or re-enabled before clear | ack before completion, clear before unmask, storm budget limits the damage |
| Double reclaim | ledger counts drift, memory reuse races | single-owner, single-pass reclaim |
| Silent slot leak | occupancy drifts to full over time | conservation check on every error path |
| Permanent Pending | flush or waiter never settles | ticketed flush with terminal abort; epoch check on every completion |
