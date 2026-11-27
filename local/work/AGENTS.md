# local/work/: task records

One file per task, `<id>.md`, with id `YYYY-MM-DD-slug` (the day it was opened, and a slug of at most 18
characters that names the subject in two or three words, different from every existing id). The slug becomes the
task's session names (`launch` step 4), so it is never only a ticket number; the ticket goes in `source`. Create it
when the task opens. The Answer workflow gets a record only when
it produced a decision or a follow-up.

```markdown
---
id: 2026-01-31-fix-login
project: <name from the registry, or none for a task of no project>
workflow: build
opened: 2026-01-31 14:05
not_before:         # act, or look again at what it waits on, from then: 2026-02-07 or 2026-02-07 09:30
due:                # a deadline someone set; most tasks have none
waiting_on:         # who or what other than the user: a reviewer, a release
needs_user:         # optional scalar: local ask time and a short cue for the pending decision
closed:
outcome:
branch:             # where the project uses them; one per repository when the task changes several; the same for pr
pr:
worktree:           # a worktree or copy made for this task alone, while it exists; one per repository when the task changes several
sessions: []        # each "claude:<session id>", "codex:<session id>" or "agy:<session id>"
source: <where the ask came from: the user, an issue link, a follow-up of [[other-id]]>
---
## Asked
The request, in the user's words where short.
## Done when
What must be true and how it will be shown: the workflow's "Done when", made specific to this task; for a
change, the project's definition of done. The user's own words win.
## Timeline
- 14:05 opened
- 14:12 builder launched (claude:<id>, address t7)
## Questions and answers
- 15:02 Q: <what you asked>  A (15:40): "<the user's words>"
## Decisions
- <decision>, because <reason>
## Outcome
What happened, with evidence: commands and their results, and where the change is (files, commit, pull request).
## Follow-ups
```

- **Status is read from the record and the multiplexer.** Empty `closed` means open. Read pending decisions with
  `.agents/skills/wrap-up/scripts/open-tasks --needs-user`. What a session is doing comes from the multiplexer.
- **Ask and answer in the record.** Before sending, write the full question verbatim in "Questions and answers"
  and, in the same edit, set a scalar such as `needs_user: "2026-01-31 15:02 — Approve login fallback for review"`.
  The cue belongs to an outstanding question you asked. Clear it if the question was never sent. A voluntary
  tab hold stays in the Timeline (`finish` step 4). If the user must answer or act in another tab, name that
  tab as they see it and who acts, in the cue and the prompt. For a batch,
  use one cue for the outstanding decisions in that section. Record each answer verbatim and keep the cue current
  until the last answer, then clear it to `needs_user:`. A missing field also means no pending decision. Use
  an open follow-up record when the parent has closed or the decision needs to outlast its closure.
- **A date or a wait is a field,** so that it can be listed: `.agents/skills/wrap-up/scripts/open-tasks` prints
  the open records as overdue, due today, arrived, open, waiting or later, and no written list of them is kept.
  Use `waiting_on` for a real dependency outside the user's decisions. A wait gets a `not_before` for the next
  look. Take a date from `date`. When the look or wait is over, clear the field or set the next one.
- **Accepted follow-ups** name the next actor and observable trigger in Follow-ups. Add a date when agreed or
  useful for the next check. For an explicit deferral, put one line there starting `parked:` with the actor and
  resumption trigger. The scanner still lists it as open. Wrap-up uses that line to decide when to resume.
- `outcome` is one of `delivered`, `answered`, `dropped`, `failed` (ended without its result), set with
  `closed` by the `finish` skill.
- Session ids are kept because they resume a session and find its transcript. Paths are leads that break.
- `wrap-up` moves a closed record to `archive/<YYYY-MM>/` by its `closed` month. Records are kept for good.
