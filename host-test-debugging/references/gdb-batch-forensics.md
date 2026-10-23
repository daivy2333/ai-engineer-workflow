# gdb Batch Forensics for Host Test Binaries

Take real state values from a failing host test when static reading and the printed snapshot contradict. Read-only: no target mutation, no repository changes beyond build artifacts.

## Locate the binary and real symbols

```sh
ls <pkg>/target/debug/deps/<test>-*            # the binary matching the run
nm -C <binary> | grep -i <method>              # real crate and symbol names
```

- A crate renamed inside the binary (workspace renames, crate merges) means source-name breakpoints silently never hit. Use the full demangled symbol from the `nm -C` output.
- With the debugger's default ASLR-off behavior, addresses of statics and large allocations stay stable across runs: addresses recorded in one session can be reused for raw dumps in the next.

## Batch skeleton

```sh
gdb -batch -q \
  -ex 'set pagination off' \
  -ex 'break <full-symbol>' \
  -ex 'ignore 1 <N-1>' \
  -ex 'run' \
  [-ex 'continue'] \
  -ex 'p <expr>' \
  --args <binary> --test-threads=1
```

- Test runner arguments must go through `--args` after the binary; passing them as debugger options fails with an unrecognized-option error.
- One failing `-ex` can silently discard the rest of the script — an unquoted `break *<sym>` is the classic. Verify the breakpoint was actually set before trusting a "never hit" conclusion.

## Phase selection

- `ignore 1 <N-1>` skips the first N-1 hits; the Nth hit is the failing phase when the failure happens on the Nth iteration.
- After the hit, a short backtrace (`bt 3`) must agree with the test source line; only then take values.
- Two-stage deep breakpoints: set the outer phase breakpoint in the initial script; after it stops, add the inner breakpoint and `continue`, so the inner one only sees that phase's events instead of replaying all early history.

## Value extraction, in order of trust

1. Typed prints at a breakpoint on a line inside the function body: `p self.<field>` — type-aware and the most reliable.
2. Whole-collection one-shots: `set print elements 300` then `p *<box-field>.data_ptr@<len>` — print the entire backing in one expression, never element loops.
3. Raw dumps: `x/Ngx <addr>` — the compiler reorders struct layout, so raw field order differs from source; raw dumps are evidence only when cross-checked against a typed print.

## Event reconstruction between stops

Dump the same field set at two stops (first `run`, then `continue`): the delta is what happened between them. Counter deltas name how many operations occurred; the identity of new entries names what kind — enough to overturn a static attribution of a single value.

## Cost control and output filtering

- Each batch run replays the whole test (tens of seconds typical): merge print commands per session and reuse recorded addresses instead of re-stopping.
- Pipe output through a grep for the labels, stack frames, and panic lines; full hundred-item prints drown the finding.

## Dead ends, measured — do not retry

- A `commands` block referencing `self` (or any context variable) errors and aborts the remaining command list — the program stays stopped and the batch session hangs until timeout. Take state with top-level `-ex` prints after the stop instead.
- An unquoted `break *<sym>` aborts the whole script silently; the run proceeds with no breakpoints.
- `watch` before the target memory is mapped never triggers; set watchpoints only after a stop that guarantees the memory exists.
- `printf` with struct parameters or `sizeof(...)` in the format arguments is a syntax error; use `p` or raw dumps.
- Type casts (`p *(Type*)addr`) may yield nothing in some setups: prefer body-line breakpoints; use casts only as a fallback and confirm nonempty output in the same session.
- `debug_assert` silence proves "path not executed" only when the build keeps debug assertions on; verify the package has no profile override first.

## Stop rules

- Three failed rounds at the same phase: change phase or failure evidence (the three-strike rule).
- A hang with no panic and no exit after a breakpoint hit usually means a command list aborted: rerun with a flat `-ex` sequence before suspecting the test.
