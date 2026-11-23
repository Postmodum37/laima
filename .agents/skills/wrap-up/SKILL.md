---
name: wrap-up
description: Use when the user ends the day, asks for a wrap-up or a check that nothing is dropped, or before a long Laima session is cleared.
---

# Wrap-up

1. **Look at every session**: the ones you tagged, finished ones included, and the plain listing for agent
   sessions without your tag (multiplexer adapter § See all sessions). Look also at every record in
   `local/work/` outside `archive/`; `scripts/open-tasks` in this skill's folder lists the open ones with their
   dates and waits. Pair them by the ids the records hold (`sessions`, and the addresses on their Timeline), not
   by the tag alone. Done when each session and each record is in one of the cases of step 2.
2. **Settle each one:**
   - A task whose work is done but which is not closed: run `finish`.
   - A task waiting on the user: keep it for the report in step 10.
   - A task waiting on other people (an open pull request): look at its state now. Merged: run `finish`.
     Changes requested or checks failed: take the workflow's next step.
   - A task listed as overdue, due today or arrived: take its workflow's next step, or look at what it waits on
     and set the next `not_before`. One listed as waiting or later: leave it until its date. One that comes due
     tomorrow: keep it for the report in step 10.
   - A task with a session that is working: leave it; note it as running on.
   - A task whose session is blocked, in error, ended, or idle without a report: read its screen and treat what
     it shows as its report.
   - Any other task with no session and no open question: it stalled. Take its workflow's next step, or ask
     the user.
   - A closed or archived task with a session of yours still listed: close the session (`finish` step 4).
   - A session tagged as yours that no record names is unknown: tell the user it is there, and leave it.
   - A live session that shows no status: read its screen.
   - A record listed as unreadable: read it, repair its frontmatter from its body where it shows what was
     meant, otherwise tell the user it is there.
   - An agent session without your tag is the user's: mention it, offer to adopt it, and leave it.
3. **Check the writes** for each task touched since the last wrap-up. Every launch has a session id in the
   record and a `launched` line in the log; every question has an answer or is still waiting; every closed task
   has an outcome with evidence. Add what is missing, marked "(added at wrap-up)". Done when you have a count of
   the misses you repaired, zero included.
4. **Archive** each closed record to `local/work/archive/<YYYY-MM>/`, after noting it for step 6.
5. **Consolidate:** run the `consolidate` skill.
6. **Rebuild `local/index.md`**, keeping its headings: "Needs the user" from the open records' unanswered
   questions and each earlier line that is still unanswered, "Recently finished" from the records closed since
   the previous `rebuilt` time, the knowledge map from the knowledge folder, projects from the registry. Set
   `rebuilt` to the time from the clock.
7. **Log** a `wrap-up` line: tasks open, closed since the last wrap-up, waiting on the user, sessions left
   running, writes repaired.
8. **Check the core:** `git status -sb` in the Laima folder. Report uncommitted core changes, and commits ahead of
   the remote that wait for the user's word to publish; committing them belongs to the `authoring` skill.
9. **Commit the vault,** its undo, from the Laima folder: `git -C local add -A && git -C local commit -qm "wrap-up
   $(date '+%F %H:%M')"`; a day without writes prints `nothing to commit`. Where `local/.git` is missing, run
   `set-up`, which makes it. Done when `git -C local status --short` prints nothing.
10. **Tell the user**, in this order: what needs them, what comes due tomorrow, what runs on without them, what
   closed. Then sign off.

Verified: 2026-11-22, Claude Code 2.1.327 to 2.1.330 and Codex 0.170.0. Not yet run: with workers still running; step 8 with commits ahead; step 9 on a vault that already has its repository; a tagged session no record names; a record listed as unreadable.
