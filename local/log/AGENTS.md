# local/log/: what happened, by day

One file per day, `YYYY-MM-DD.md`, append-only. One line per write moment, added in the turn it happens:

```
- HH:MM [[task-id]] <event> — <detail> (<role> <harness:id>) → <evidence>
```

- `(<role> <harness:id>)` names the session involved; leave it out when none is, and leave the id out of a
  `launched` line when the harness has not issued it yet: the record takes it once known.
- `→ <evidence>` is a commit, pull request, command result or record section; leave it out when there is none.
- A line about no task (set-up, wrap-up) uses `[[laima]]` in place of a task id.

| Event | Write it when |
|-|-|
| `opened` | A task record is created |
| `launched` | A session starts for a step, or one the user started is adopted |
| `handed-off` | A step's result passes to the next step |
| `asked` | Before sending a question, record it under Questions and answers and log it here. A question still open when your turn ends also gets its line under "Needs the user" in `local/index.md`; one answered in the same turn, as in a dialog, gets none. Include follow-up decisions requested in a delivery or wrap-up, even after the task closes. |
| `answered` | The user answers; remove the question's line from `local/index.md` where it has one. Also when you answer a session's dialog under the root's § Authority: name the session and where the answer came from |
| `failed` | A session or a step fails; the task stays open |
| `finished` | A task closes as delivered, answered or failed; the detail opens with the outcome |
| `dropped` | A task closes without delivery; say why |
| `promoted` | A lesson, preference or fact moves into `knowledge/`, `user.md` or a project note |
| `wrap-up` | A wrap-up ran; say what it found |
| `set-up` | Set-up changed the vault; say what |
| `usage` | You read the remaining usage for a launch: the provider's figures, and whether it is running short |

Example: `- 16:20 [[2026-01-31-fix-login]] handed-off — build verified, review requested (builder claude:3f2a) → commit 9c1e2d4`

Routine progress stays out: the log answers "what changed", and the multiplexer answers "what is running now".
`consolidate` summarises a month in `YYYY-MM-summary.md` once it is about 30 days past and moves its daily files
to `archive/<YYYY-MM>/`.
