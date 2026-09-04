---
name: feedback-projectd-loop-cycle-cleanup
description: "When D:\\Claude\\ProjectD's loop/loop.sh restarts (ITER counter resets to iter_1), analyze and report the previous cycle's logs before deleting them."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 08652cec-13b7-48ef-866d-b76e8abb51e2
  modified: 2026-09-04T04:35:39.764Z
---

When `D:\Claude\ProjectD\Util\loop\loop.sh` (path as of the 2026-09-02 root reorg; was `loop\loop.sh` before) is restarted, its internal `ITER` counter resets to 1 (it's a local script variable, not persisted), so a fresh `iter_1_<timestamp>.log` appears in `Util/loop/logs/` alongside the previous cycle's `iter_1..N` logs (each filename is unique because it embeds a timestamp).

**Rule**: the moment a new `iter_1_*.log` appears while older logs from a prior cycle are still sitting in `Util/loop/logs/`, analyze all of those prior-cycle logs, report a per-iteration summary to the user (result: success/commit hash, or hang/failure and why), then delete them.

**Why**: the user explicitly asked for this as a standing behavior (2026-09-02) rather than a one-off — raw iteration logs are transient/noisy, but the user wants a synthesized record of what happened each cycle before the logs are cleared out. `docs/STATUS.md` (maintained by the loop's own agent each iteration) already carries the durable "what got done" record, so deleting the raw logs after reporting doesn't lose project history.

**How to apply**: this project runs an autonomous headless loop (`claude -p`) driven by a background Monitor watching `Util/loop/logs/`. The monitor script should flag the restart-detected event (new `iter_1_*` file while other iter files are already known/processed) as a distinct notification. On that notification, read each of the prior cycle's log files, produce a compact table/summary (iteration number, success or failure, one-line description, commit hash if any), post it to the user, then `rm` those files — leaving only the new cycle's `iter_1_*.log` in place. Repeat every time a restart is detected, for the life of this project's loop.

**Monitor reliability caveat (2026-09-04)**: a background Monitor watching `Util/loop/logs/` left idle for ~15h (nothing changed on disk — no new logs, HEAD unmoved) started emitting garbled, duplicate "iteration complete" events for files it had already correctly reported hours earlier (wrong/mangled content text, stale commit attribution). Always cross-check a Monitor event against ground truth (`git log`, `ls` the log dir, `ps aux` for a live `claude` process) before reporting it to the user, especially after a long idle gap — if the notification disagrees with reality, trust the direct check and just restart the Monitor rather than debugging the stale one.

See also [[project_projectd_loop_ops]] for the broader operational context (sleep-mode hangs, timeout watchdog, off-screen QA window fix) this project has needed.
