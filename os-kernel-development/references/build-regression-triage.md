# Build and Regression Triage

How to classify build and test failures before debugging them, and how to land multi-commit work without losing attribution. Written for kernel projects where agent environments, cross-platform targets, and large staging branches mix.

## Classify a build failure

Judge by three facts, in this order: the exact command, the final exit code, and whether the expected artifact was produced by the real tool.

- Final exit 0 with the artifact produced: PASS. Earlier warnings from the environment — a read-only package home, no network, auto-install notes — are noise and do not downgrade the result.
- Final nonzero with product diagnostics (compile, link, or test errors): product FAIL, even when environment warnings appeared earlier. Fix the product layer; the environment did not cause it.
- Final nonzero with only environment refusals (permissions, EPERM, missing hardware, sandbox blocks) and no product layer reached: environment-blocked. Keep the command and exit code, and ask for a same-command rerun in a normal environment.
- The command does not match the product — wrong target, wrong feature set, wrong platform config: invalid evidence. It is neither PASS nor product FAIL and does not count toward a failure streak. Re-run with the project's real product command.

Find the earliest layer that decided the outcome: command choice → dependency probe → compile → link → objcopy or artifact check. Classify with the earliest decisive layer, not the loudest warning.

- Tool availability is proven by invocation, not by package-manager listings: a failed `install --list` probe followed by a working tool call means the tool exists.

## Cross-verification boundaries

- A user rerun only clears the doubt it shares: the same product command in a normal environment clears an environment block; a different platform's success only proves the shared toolchain, never the failing platform's gate.
- Fix the failing platform's product command; do not swap commands until one passes.

## Did my change cause it?

Before debugging a failure that appeared after a large uncommitted change, answer whether the change introduced it.

1. Record the full status snapshot, stage everything including untracked files (untracked files do not enter a stash by default), stash, and verify the clean baseline.
2. Clean the build cache before judging the baseline: stale incremental artifacts from the changed tree make the baseline falsely fail — undefined-symbol errors are the typical signature.
3. Restore the change in dependency-ordered blocks and verify each block: a passing block is out of scope, a failing block narrows the search. One failing path in a multi-path restore command aborts the whole restore; restore paths one at a time.
4. Cross-check ambiguous results with a same-command rerun in the user's environment: agent build FAIL plus user run PASS on the same tree is environment or cache noise.
5. Verify restore completeness against the snapshot before dropping the stash; a stash dropped too early is recoverable through fsck or reflog before any other git write. If a stash pop conflicts mid-restore, extract both index stages (`git show :2:<path>` and `:3:<path>`), restore the intended staged/unstaged boundary with index surgery (`git update-index --cacheinfo`), and verify restored line counts against pre-edit values.
6. This pass is attribution, not debugging: when every block passes alone and the combination fails, the failure is an interaction — change dimension (feature combinations), do not keep bisecting the same axis.

## Integrating multi-commit work

- Never apply a whole branch at once. Split by dependency order, not commit order: the measurement or evidence layer first (it provides the baseline the rest is judged against), minimal fixes second, contract or interface convergence third, pure trait or API signature changes last (they depend on stabilized internals).
- Gate every step: compile, lint, boot or run, and the deltas the step claims. A step that regresses past the agreed tolerance stops the sequence and gets its own diagnosis.
- Keep the source branch until the integration is complete; it is the rollback point.

## Parallel host-test pollution

Kernel-adjacent host tests often share process-global state — a static registry or a global set. Parallel runs then fail intermittently:

- A failure that always passes on isolated rerun is nondeterminism, not a product regression. Attribute before counting: deterministic replays (single-threaded ×100, unaffected subsets in parallel ×100), failure-surface signals (third-party internal assertions, allocator corruption, signals), and control-group experiments (byte-level revert of the diff; indistinguishable failure rates mean the race predates the change).
- Track known flakes separately; never silently exclude them from a run.
- See the host-test-debugging skill for the full triage workflow.

## Transfer-ceiling traps at syscall boundaries

- A layer that silently caps per-call transfer size — for example a read path delivering at most N bytes per call — combined with tools that treat short reads as complete blocks produces silently wrong results with exit 0.
- Expose per-call ceilings in the device or syscall contract, and validate full-quantity assumptions with byte counts at the receiving end, never with tool exit codes alone.
