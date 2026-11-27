---
name: wrap-up
description: Use when the user ends the day, asks for a wrap-up or a check that nothing is dropped, or before a long Laima session is cleared.
---

# Wrap-up

1. **Look at every session**: the ones you tagged, finished ones included, and the plain listing for agent
   sessions without your tag (multiplexer adapter § See all sessions). Look also at every record in
   `local/work/` outside `archive/`. Run `scripts/open-tasks` in this skill's folder in both default and
   `--needs-user` modes. Read each pending decision record and each record listed as overdue, due-today, arrived
   or open. Pair sessions to tasks by the ids the records hold (`sessions`, and the addresses on their Timeline), not
   by the tag alone. Done when each session and each record is in one of the cases of step 2.
2. **Settle each one:** reconcile the records in this pass against current state and recorded decisions.
   Use `finish` step 4 to recheck idle workers, delivered drafts and holds whose release event has arrived.
   - An open record with a `parked:` line in Follow-ups: resume its workflow once evidence shows the named
     trigger fired, and clear the line when it resumes. Until then, leave it open and skip stalled classification.
   - A task whose work is done but which is not closed: run `finish`.
   - A task with an asked decision still outstanding: keep it for the report in step 10.
   - A task waiting on other people (an open pull request): look at its state now. Merged: run `finish`.
     Changes requested or checks failed: take the workflow's next step.
   - A task listed as overdue, due today or arrived: take its workflow's next step, or look at what it waits on
     and set the next `not_before`. One listed as waiting or later: leave it until its date. One that comes due
     tomorrow: keep it for the report in step 10.
   - A task with a session that is working: leave it; note it as running on.
   - A task whose session is blocked, in error, ended, or idle without a report: recover its report or read
     its screen as `launch` step 7 directs.
   - Any other task with no session and no open question: it stalled. Take its workflow's next step, or ask
     the user.
   - A closed or archived task with a session of yours still listed: apply `finish` step 4 to release it.
   - A session tagged as yours that no record names is unknown: tell the user it is there, and leave it.
   - A live session that shows no status: read its screen.
   - A record listed as unreadable: read it, repair its frontmatter from its body where it shows what was
     meant, otherwise tell the user it is there.
   - An agent session without your tag is the user's: mention it, offer to adopt it, and leave it.
   Bring a rolled item back to the user when a relevant event, useful check or concrete decision makes it
   actionable. If several rolled records need the same review, check the evidence together and group the
   choices with each record's own next actor and trigger. Done when each record has a current disposition.
3. **Check the writes** for each task touched since the last wrap-up. Every launch has a session id in the
   record and a `launched` line in the log. For the records checked, clear stale dependencies and cues and repair
   missing cues for questions actually asked and still unanswered. Match each to its full question as
   `local/work/AGENTS.md` describes. Each closed task
   has an outcome with evidence. Add what is missing, marked "(added at wrap-up)". Then search for times written
   with a placeholder digit, such as `17:3x`, which `local/Laima/AGENTS.md` § Writing here, "Times", rules out:
   `grep -n -E '[0-9]:[0-9xX][xX]' local/work/*.md local/Laima/index.md local/Laima/log/*.md`
   Correct each one in place, with a time taken as that rule says, marked "(time set at wrap-up)". In the log this
   is the one edit its append-only rule allows. Done when you have a count of the misses you repaired, zero
   included, and the search shows no placeholder time.
4. **Archive** each direct closed record to `local/work/archive/<YYYY-MM>/`. Collect its ID and outcome before
   moving it. Check that the original is gone and the record is present in the folder for its `closed` month.
   Done when each destination is verified. Use that same set for what closed in step 10.
5. **Consolidate:** run the `consolidate` skill.
6. **Refresh the decision list for the report:** run `scripts/open-tasks --needs-user` after the repairs and closures.
   Report only the asked, unanswered choices the user can act on.
7. **Log** a `wrap-up` line: tasks open, closed and archived in step 4, waiting on the user, sessions left
   running, writes repaired.
8. **Check the core:** `git status -sb` in the Laima folder. Report uncommitted core changes, and commits ahead of
   the remote that wait for the user's word to publish; committing them belongs to the `authoring` skill.
9. **Commit the vault,** its undo, from the Laima folder: `git -C local add -A && git -C local commit -qm "wrap-up
   $(date '+%F %H:%M')"`; a day without writes prints `nothing to commit`. Where `local/.git` is missing, run
   `set-up`, which makes it. Done when `git -C local status --short` prints nothing.
10. **Tell the user**, in this order: what needs them, what comes due tomorrow, what runs on without them,
    and the IDs and outcomes collected in step 4. Then sign off.

Verified: 2026-11-23, Claude Code 2.1.330 (step 3's time search); 2026-11-22, Claude Code 2.1.327 to 2.1.330 and Codex 0.170.0. Not yet run: both scans and the archive-to-report flow in a session; the retargeted time search in a session; with workers still running; step 8 with commits ahead; step 9 on a vault that already has its repository; a tagged session no record names; a record listed as unreadable; explicit parks with fired and unfired triggers; archive destination readback and reconciled decisions in a session.
