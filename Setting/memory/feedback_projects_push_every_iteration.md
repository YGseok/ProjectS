---
name: feedback-projects-push-every-iteration
description: "ProjectS (D:\\Claude\\ProjectS): push to GitHub after every self-directed iteration, not just at the end of a batch."
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a4f2d0d6-106e-4808-8745-d07c879caf22
  modified: 2026-09-08T10:09:36.075Z
---

In ProjectS, when running self-directed iteration batches (e.g. "이터레이션 N회 돌려줘" or an open-ended "계속 돌려줘"), push each completed iteration's commit to `origin/master` immediately — don't batch pushes until the end of the run.

**Why:** User explicitly asked for this as a standing rule (2026-09-08), after initially only pushing on request. They wanted the remote to stay current per-iteration, especially relevant when they're stepping away for an extended period (told me they'd be gone 12+ hours) and want to be able to check progress from GitHub itself rather than waiting for a final push.

**How to apply:** After each iteration's commit (following the project's existing sync-to-repo.ps1 → add/commit → push workflow per `CLAUDE.md`), run `git push origin master` right away before starting the next iteration. This applies specifically to ProjectS's iteration-batch workflow — doesn't necessarily generalize to every project unless similarly instructed.
