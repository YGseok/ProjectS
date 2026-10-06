---
name: thread-scope-artwork
description: "A ProjectS thread dedicated to artwork — resource list, ordering (발주) from the human artist, and applying received sheets"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 560d474b-c86d-4c1d-9ae8-fe8c2ed50b20
  modified: 2026-10-06T09:08:40.047Z
---

User designated a thread (2026-10-06) as ProjectS's artwork owner: 필요 리소스 리스트 기록, 리소스 발주, 리소스 적용.

**Why:** art is produced by the human from order specs; Claude tracks needs and integrates sheets. No third-party packs (v0.34+).

**How to apply:** in that thread, work through `docs/art/` (RESOURCE_LIST.md, orders/ORDER-NNN.md, README workflow) and keep `assets/README.md` mapping updated on every application. Don't invent new art/story — orders go to the human. Same style as [[thread-scope-pc-sync]] scoping; Korean responses per [[projects-korean-notes]].

**Auto-push (2026-10-06):** user said "작업되는 것들은 알아서 깃허브에 올려줘" — after each art work unit, commit and push without asking (run `Setting/sync-to-repo.ps1` first per CLAUDE.md). See [[projects-push-every-iteration]].
