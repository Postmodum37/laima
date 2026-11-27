---
name: launch
description: Use when a workflow step needs a worker session started, when a closed session must be resumed from its id, or when the user asks you to track a session they started (adopt).
---

# Launch

Starts one session for one step of one task. The task record exists first (`local/work/AGENTS.md`).

How each action is done with the tools on this machine is in two adapters, named in `local/Laima/setup.md`:
`adapters/multiplexers/<multiplexer>.md` and `adapters/harnesses/<harness>.md`. Their section names are used below.

## Steps

1. **Read the ground:** the role file `roles/<role>.md` (`local/Laima/roles/<role>.md` for a role of the user's
   own); the project's line in `local/Laima/projects/registry.md` and its note when one exists (a task that belongs
   to no project, such as research on an outside question, has neither: its record says `project: none` and
   its worker starts in its task folder); the row for this
   session (§ Which harness, model and effort). Then find what the project and the user already have for this
   step, because theirs comes before anything of yours: the project's instruction file, the skills in its own
   skill folders, the user's global skills for the worker's harness (harness adapter § Instruction files it
   loads names the folders), the user's global instruction files, the files that section says load from the folders
   above the session's folder and above the project's checkout, `local/Laima/user.md` § Their rules, and the
   tools in `local/Laima/setup.md` § Tools found. Note each skill, command, gate
   and rule of theirs that covers part of the step: making and shipping a change, tests, review, commits, pull
   requests, the issue tracker. Check that the project's folder exists. Done when you can name the folder, the
   harness, model and effort with the reason for them, where and how the change is made, and what of the
   project's and the user's own the brief will name.
2. **Prepare the workspace.**
   - **The task folder,** `<task folders>/<task-id>/` (`local/Laima/setup.md` § Workspaces), holds the briefs,
     reports with their messages, and plans, and nothing else.
   - **Where a builder makes its change is the project's:** its own instructions, the user's global ones and
     the note's § Workspaces say whether work happens in the folder itself, on a branch or in a worktree, and
     how many tasks may change it at once. The builder sets that place up itself, by those rules: the brief
     says so and asks it to report what it made. Prepare the place yourself only where the note puts that on
     you. When none of them says, ask the user once with your recommendation, and write the answer into the
     project note. "In place" means edits in the project's folder as it stands, with no branch and no commit
     unless its rules ask for one. Until a rule gives tasks separate places, one task changes a folder at a
     time; when no place is free, the task waits and you tell the user.
   - **Every other role changes nothing in the project:** it works in the project's folder, or where the work
     under review is, and writes its notes and report in the task folder. When the work to review is checked
     out nowhere, give the reviewer its own copy by the project's means and note its path in the task record for
     `finish`. Under git, make a detached worktree at the review pin and record the pin too.

   Done when the task folder exists, the brief says where the change is made or that the builder sets the place
   up, and any detached reviewer copy has its path and pin in the task record.
3. **Write the brief** to `<task folder>/brief-<role>.md` (§ The brief); when the task folder already holds a brief for
   that role, number the new one and its report file: `brief-<role>-2.md`, `report-<role>-2.md`. Done when every check
   there holds or plainly does not apply, and the file on disk holds no character you did not mean:
   `LC_ALL=C grep -n '[^ -~]' <brief-file> | LC_ALL=C cat -v` lists each line with a character outside
   printable ASCII, and you can say why each is there. One gets in when an escape sequence you typed is
   written as the character it names, which the worker then cannot see. The Rex send block carries the prompt
   glyphs `❯` and `›` on purpose; its lines are expected in that list.
4. **Start the session:** multiplexer adapter § Start a task session, with the argv from the harness adapter § Launch
   with a brief and each launch flag that the rules found in step 1 give for a session in that folder, such as a
   second folder to add, on resume as well, written for this harness and placed where its adapter says (right after
   the program's name where it says nothing). A flag the adapter's argv already carries (mode, model, effort) keeps
   the value § Which harness, model and effort gives. Name it `<subject>-<name word>`: the subject is the task id
   without its date, the name word is the role file's. A second session of the role in the task adds its harness when
   that differs from the first one's (`-review-codex`), otherwise `-2`; a name a live session already holds then adds
   `-2` at the end, or the next free number. When the name would pass the adapter's limit, drop words from the end of
   the subject until it fits (an id opened before this rule can be long). The name is the user's handle on the session
   in the multiplexer's list, so it carries no date (the tag holds the id) and it stays as set; the adapter's § Start
   a task session gives its limits and any prefix. Tag it with the task id, and start it in the place for the change,
   in the project's folder, or, for a task of no project, in its task folder; when a task spans several, in the one
   holding most of the work, with the others listed in the brief. Two cases start without the brief, which you send as
   the next message (multiplexer adapter § Message a session): where the harness adapter § Launch with a brief says a
   first turn there would run before the trust prompt is answered, send it once the prompt is answered and the session
   is at its prompt (step 6); and where the step begins with a command that only a typed prompt starts, such as a
   skill the project closes to the model, that command is the first prompt in the argv, and you send the brief, report
   block included, in the same turn as the launch: record the session first (step 5), with "brief pending" on its
   Timeline line, then send the brief once its input is free, at its prompt with no dialog open, whether the command
   is still running or has finished (a running turn counts where the harness takes typed input while it works).
   While "brief pending" stands, check for receipt at the next look and retry a failed send using the adapter's
   message guidance. Clear the entry only when step 6 verifies the intended brief reached the worker.
5. **Record it** as soon as the start command returns, before anything else can go wrong: a Timeline line with the role,
   address, harness, model, effort, mode, each flag step 4 added and the folder it started in; the `worktree` field once
   a place was made for this task alone (at once when you made it, from the builder's report when it did), and `branch`
   when there is one; a `launched` line in today's log that names the model, the effort and why that row. Add the
   session id (harness adapter § Session id) to `sessions` and to that Timeline line once you have it. Done when the
   record and the log both show the session.
6. **See it working:** check its folder, actual placement against the chosen space or tab where applicable, and
   project-required flags against the running session using the adapters' listing and screen checks. Verify the
   intended brief in the worker's conversation or from the worker's acknowledgement, including after a typed
   first command. A session in a folder the harness has not seen can stop at a trust prompt (harness adapter
   § Gotchas says when). `AGENTS.md` § Authority says when that prompt is yours to answer, and which other dialog
   is theirs. A session that failed to start gets a `failed` line in the log and the record. Done when the running
   session and its brief match the launch, or the remaining wait or failure is recorded.
7. **Go on.** The worker reports by message; how it reaches you is in the multiplexer adapter § How you learn
   a session finished. End your turn or take up other work; a foreground wait would keep the user, and the
   report, out of your session.
   When an expected report is missing, check its report file in the task folder and read the screen for
   anything the file leaves unresolved. Verify the worker and phase before using the result. Keep a later
   tagged copy as receipt for that phase, and advance the workflow once.

## Which harness, model and effort

`local/Laima/setup.md` § Roles is the one place that says: a usual row per role, a raised row with the condition for
it, a row for when a provider is running short of usage, and the user's rule for today when they gave one.

1. Take the role's usual row, or its raised row when this step meets the condition written there. A project
   note's pin and the user's rule for today come before both; the user's pick for this launch comes first.
2. Use the latest `usage` line in today's log for the row's provider. Take a new reading of that provider alone
   (its harness adapter § Remaining usage) and log it when today's log has none for it, when the line is hours
   old, or when a session has stopped on a limit since; read the fallback's provider too before you move a step
   there. One reading serves every launch until then.
3. When the reading shows the row's provider running short, by the guidance in that section, use the row's
   entry for that case and tell the user once in this session, with the reading. Usage moves a step to another
   provider; it never picks a weaker model than the row names. When no entry fits, ask the user.
4. Say the row and its reason where the user sees it: in a plan's approval question, and in the `launched` log
   line. When you see a reason for a stronger or cheaper row than the table gives, recommend it; their pick wins.

## The brief

The worker loads its project's instructions and the user's global ones, and nothing of Laima's. Those govern
how it works. The brief adds the task and what the worker cannot load, once.

1. **Header:** the task id, the role, the outcome wanted in a line, and why it is wanted.
2. **The ask:** the user's words where short. Every work item above everything else, each with its done
   condition.
3. **Ground:** the working directory and, under version control, the branch and the commit it starts from; how
   a change is made and shipped in this project, when its own instructions do not say. What is known, each fact
   marked *checked* or *lead* (someone said so). *Checked* means you ran or printed it while writing this brief
   and copied from that output, because the worker builds on the brief as true: what a file contains from a print
   that shows every character, such as Python's `repr()` (`od -c` and rendered Markdown make a run of spaces
   hard to count), and what code returns from running it.
4. **Authority:** state what the role may change. When a step depends on a recorded decision, outward action
   or project grant, quote the applicable choice or rule and its source. Give the actor, action and effect,
   with its target or stage. For an open gate, name the decision owner, the exact held step and what releases it.
   For a standing project grant, include its conditions, exceptions and report-back. Carry these into resumed
   or changed instructions and check for newer decisions before releasing a step. Send any outward proposal
   beyond the grant privately to the lead for a draft or decision. Hold that action and continue independent
   work. The named internal report route in item 8 is the worker's handback.
5. **Evidence:** what must be shown before reporting done. Name a command only for a gate the project requires.
6. **Role extras:** the role file's "In the brief" list.
7. **Their own way:** each skill, command, gate and rule from step 1 that covers part of this step, by name,
   and nothing of yours in its place: the project's instructions and the user's global ones outrank this brief
   where they differ. Name a skill only when this harness can load it; otherwise give the path of its file to
   read.
8. **Report:** the block below. Its `<report file>` is `<task folder>/report-<role>.md` and its `<message file>` `<task
   folder>/message-<role>.md`, numbered with the brief (step 3). Its send slot takes the worker's send from the
   multiplexer adapter § How you learn a session finished, copied whole, with your address and the task's tag written
   out. The harness adapter § How a worker reports back says when the worker's mode can stop that command.

```
When you are done, blocked, or need a decision: first write your full report to <report file>
(add to the file when it exists), then write the message below to <message file> with your file tool, not
through a shell (replace the file when it exists), then send Laima that message and stop and wait:
<the worker's send from the multiplexer adapter>
The message:
    [report <task-id> <role>] done | blocked | question
    <what you did or found, in at most five lines>
    Evidence: <commands with results; where the change is (files, commit, pull request); the report file's path>
    Needs: <the decision or input you need, or "nothing">
Send one message per report, complete in itself, and no progress updates. Follow the send block's retry
instructions for known refusals. For an ambiguous result use the adapter's readback guidance before retrying.
For other failures, retry after a few seconds, up to three times, once you have checked the earlier attempt
did not arrive. Then stop: Laima reads the report file. Start no other agent sessions; the subagents of your
own harness, such as a review skill's, are not sessions.
```

## Resume a closed session

Use the harness adapter § Resume from a session id as the argv in step 4, in the folder the session first ran in (the
launch's Timeline line names it). Run step 1's search for rules again for that folder and add the flags it gives,
together with any the Timeline recorded; where they differ, the current rules win. Give a first message saying what
changed and what is wanted now. Add a Timeline line and a `launched` log line saying "resumed". When the session's
folder went with the workspace and the adapter has you recreate it, write it into the record's `worktree` field, so that
`finish` removes it again.

## Adopt a session the user started

1. Find it in the full listing (the user's sessions carry no tag of yours) and read its screen to learn what
   it is working on.
2. Find or open its task record. Add its session id (harness adapter § Session id says how for a session the
   user started) to `sessions` and a Timeline line saying "adopted"; tag the session with the task id when the
   multiplexer adapter allows it.
3. Log `launched` with "adopted" in the detail.

An adopted session is the user's conversation: read it freely, and message or close it only when they ask.

Verified: 2026-11-26, Codex 0.172.0 on Herdr (herdr-app 0.1.18, hc 0.1.22) and Claude Code 2.1.327 to 2.1.330 (earlier). Not yet run: a session named `<subject>-<name word>` from step 4, as now worded; using the moved setup, registry and private roles in a launch; a worktree the project keeps; a worker whose send is refused; a worker's question dialog answered from the record; a worker's wait for Laima's dialog in a real brief, on any multiplexer; the worker's send block from the Herdr and cmux adapters in a real brief; the report block's line on subagents, as now worded; a numbered second brief; the record's `worktree` field filled from a builder's report; the message file and its `[report …]` first line in a real brief on Herdr and cmux; an agy launch without its brief in an untrusted folder, from this skill; a usage reading for one provider; a recreated worktree recorded at resume; a fresh session that takes today's usage line without a reading of its own; a typed command as the first prompt with the brief as the next message, as now worded; a launch flag taken from the project's or the user's rules; a brief re-sent after a refused or deferred first send; flags added on resume from the rule search; receipt and required flags at readiness, late tagged copies after file recovery, and scoped authority across handoffs.
