---
name: consolidate
description: Use when the user asks to consolidate memory or to go over what recent work taught, or when wrap-up calls for it.
---

# Consolidate

Runs on request and from `wrap-up`, never on a schedule. Read `local/Laima/knowledge/AGENTS.md` and
`local/Laima/projects/AGENTS.md` before writing there.

1. **Gather candidates** since the `consolidated` date in `local/Laima/index.md`: `lesson:` lines and Decisions in
   closed records, in `local/work/` and in `local/work/archive/<YYYY-MM>/` (where `wrap-up` has just moved
   them), review findings in those records, the user's corrections in "Questions and answers", and anything the
   user asked you to remember. Done when every record closed since that date has been read.
2. **Test each candidate:** would a later task go differently for knowing it? Drop the ones that fail; most do.
3. **Route each survivor to its one home**, updating an existing entry before adding a new one:
   - a preference or rule of the user → `local/Laima/user.md`, in their words, with the date;
   - a fact about one project that its own files do not hold → that project's note;
   - a lesson or outside fact that crosses projects → a note in `local/Laima/knowledge/`, with its line added to the
     map in `local/Laima/index.md`;
   - a way Laima herself should work differently → tell the user; the core changes only through `authoring`;
   - a review finding about a project's code that a record from an earlier task holds too, and that a linter, type
     checker or test could catch → propose a Build with the exact check. Since consolidation has no task, put the ask
     in an open follow-up for that project and link both reviews as sources. See "Ask and answer in the record" in
     [the task records guide](../../../local/work/AGENTS.md#localwork-task-records).
   Log `promoted` for the moves described in `local/Laima/log/AGENTS.md`, pointing at the source task.
4. **Repair what went stale.** A note, registry line or setup row that a task showed to be wrong is corrected or
   deleted now, with the task as the reason. Update the knowledge and project pointers in the reference map
   when their targets change.
5. **Fold old logs.** For a calendar month whose last day is more than 30 days past and whose daily files are still in
   `local/Laima/log/` (a month with its summary and no daily files left there is done), write
   `local/Laima/log/<YYYY-MM>-summary.md`
   (one line per task touched: id, project, workflow, outcome, link; then every `failed` and `dropped` line, and every
   `finished` line whose outcome is `failed`, in full; then counts per event), built from every daily file of that
   month, any already archived included. Then move that month's daily files to
   `local/Laima/log/archive/<YYYY-MM>/`. Nothing is deleted.
6. **Prune what every session reads:** in `local/Laima/index.md`, `local/Laima/user.md`, `local/Laima/setup.md` and
   `local/Laima/persona.md`, delete a line that is no longer true and move detail that only some tasks need into a
   knowledge note, linked from its line.
7. Set `consolidated` in `local/Laima/index.md` to the date and time from the clock.

Done when steps 1 to 7 each have a result you can state, "nothing to do" included.

Verified: 2026-11-26, Codex 0.172.0 on Herdr (herdr-app 0.1.18, hc 0.1.22) and Claude Code 2.1.327/2.1.328 (earlier). Not yet run: the shortened follow-up route in a live session; step 6; folding logs on real files; a month skipped as done.
