# local/Laima/log/: what happened, by day

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
| `handed-off` | A session's report is checked and written into its record (root § A task, start to finish, step 3), and its result passes on: to the next step, or in a further brief to the same session; the detail says what it found or did and what you checked |
| `asked` | A question is sent to the user. For a task question, record the question and cue before sending as `local/work/AGENTS.md` describes. |
| `answered` | The user answers and the task is updated. Also log when you answer a session's dialog under the root's § Authority, with the session and where the answer came from. |
| `failed` | A session or a step fails; the task stays open |
| `finished` | A task closes as delivered, answered or failed; the detail opens with the outcome |
| `dropped` | A task closes without delivery; say why |
| `promoted` | A lesson, preference or fact moves into `knowledge/`, `user.md` or a project note |
| `wrap-up` | A wrap-up ran; say what it found |
| `set-up` | Set-up changed the vault; say what |
| `usage` | You read the remaining usage for a launch: the provider's figures, and whether it is running short |

Example: `- 16:20 [[2026-01-31-fix-login]] handed-off — build verified, review requested (builder claude:3f2a) → commit 9c1e2d4`

Other events stay out of the log. The multiplexer answers what is running now, and decision-relevant details go
in the task record. When a worker's report and its verified handoff record the same change, one `handed-off` line
covers both.
`consolidate` summarises a month in `YYYY-MM-summary.md` once it is about 30 days past and moves its daily files
to `archive/<YYYY-MM>/`.
