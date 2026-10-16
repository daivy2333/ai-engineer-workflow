# Runtime Evidence and Diagnosis

Capture discipline and diagnosis workflows for QEMU runs of a kernel under test, interactive or scripted.

## Serial capture

- Record the guest serial for the whole session from boot: wrap the QEMU command in a terminal-recording tool with quiet mode, child exit-code propagation, and live flush (`script -q -e -f`-style).
- One session is one evidence unit: boot signature, every typed command, and the terminal PASS/FAIL marker in one transcript, so guest-side ordering is provable. A recording started after the shell cannot backfill the boot signature.
- Host-side commands that must be kept (peers, stimuli, ping, resource samplers) run through `tee` with `pipefail` on; record the pipeline status, not just the final tool's status. Binary captures (pcap) are produced by the tool itself, never piped through `tee`.
- Keep an evidence-path short variable per terminal; long paths wrapped by narrow terminals break copy-paste and script arguments.
- Two exit codes exist in every run: the emulator process exit and the guest workload's own marker or exit. Record both; neither substitutes for the other (see also linux-boot-paths.md).

## Evidence minimalism

- Keep the commands, decisive output lines, terminal markers, and exit codes that prove the behavior under test. Long raw logs stay outside the evidence set and are referenced by path when needed.
- Identity material (hashes, manifests) is not evidence of behavior; add it only when a specific process explicitly requires it.
- Guest tools can lie about the subsystem under test: a shell reporting `Connection refused` or an unsupported ioctl does not prove the dataplane is down when the kernel lacks that tool's surface. Judge by probe snapshots and wire captures, not by stock tooling.

## Offline payload injection

When the payload's own download path is the broken subsystem — the probe needs the network to fetch itself:

- Copy the disk image; never mutate the original. Write the probe into the copy with offline filesystem tools (debugfs-style write, no mount, no root).
- Boot QEMU against the copy with all other arguments unchanged, and run the probe from the guest shell by hand.
- The injected run proves whether the dataplane works with the payload present. It does not regress the download path itself; re-run the primary path once the dataplane is fixed.
- Alternatively mount the image copy read-write through a loop device when root is available; the original-image rule is the same.

## Monitor-driven fault injection

- Expose the monitor on a unix socket, and drive link events with `set_link` off/on.
- Coordinate strictly through guest-printed READY markers: send a monitor command only when the guest prints that it is ready, and confirm observation from the guest console. Pre-sent commands merge with earlier states and invalidate the observation.
- On a full-machine freeze, sample `info registers` for every vCPU (loop with a short delay) before killing the process. The all-core signature distinguishes a lost-wakeup spin (every core idle near the scheduler) from a single-core fault.
- Multi-run diagnosis prints belong behind a warn-level gate so they appear in default builds without enabling the log flood (see the SKILL.md log-level rule).

## Layered attribution with packet evidence

- Attach an on-the-wire capture (`-object filter-dump`-style) whenever the failure might be anywhere in the stack. The pcap is objective, level-independent evidence.
- Attribute layer by layer, one evidence source per layer:

| Layer | Evidence source | Pass looks like |
|---|---|---|
| Driver registration | serial log | device name, address config |
| TX dataplane | pcap | frames leaving the guest |
| IRQ → wake → reap | probe counters in guest | ISR publish, wake, reap, refill all advance |
| Slot delivery | probe snapshot | slots transition to the consuming owner |
| Stack consumption | pcap | follow-on protocol frames |
| Waiter wakeup | workload result | transfer completes |

- A pcap with only the initial exchange (for example, a resolution request and reply) and no follow-on frames localizes the break after the RX path and before stack consumption.
- Snapshot counters twice, before and after the stimulus, so the delta is attributable to the stimulus and not to background traffic.

## Environment boundaries

- Classify by final exit code and expected artifact, not by the loudest warning: environment refusals (permissions, sandbox blocks, missing tools) that never reach a product failure layer are environment-blocked, and the same command must be rerun by the user outside the sandbox; product diagnostics are product failures regardless of earlier environment noise. The full procedure lives in the os-kernel-development skill's build and regression triage reference.
- Stale emulator processes hold ports and devices: check for a running instance before blaming the launch command; kill the specific PID, not a pattern.
