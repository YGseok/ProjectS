---
name: feedback-projects-korean-notes
description: "ProjectS - always respond/summarize iteration work in Korean, not just when asked"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: a4f2d0d6-106e-4808-8745-d07c879caf22
  modified: 2026-09-14T19:45:08.344Z
---

Write iteration notes and chat summaries in Korean by default for ProjectS,
not only when the user explicitly asks ("한글로 설명해줘").

**Why:** User asked once for a Korean explanation, then in a later turn
added "이터레이션 노트는 한글로 작성해서 내가 알수있도록 할것" (write
iteration notes in Korean so I can understand them) — a standing
instruction, not a one-off request. Project docs (STATUS.md/CHANGELOG.md/
INBOX.md/commit messages) were already all in Korean throughout the
session per project convention; this extends the same default to my
own chat responses/turn summaries about the work.

**How to apply:** In this project directory, default all user-facing text
(iteration summaries, status updates, explanations of what was done) to
Korean. Code comments and doc files were already Korean-only per
[[project_projects_dev_conventions]] if that memory exists — this is
about the conversational responses specifically.
