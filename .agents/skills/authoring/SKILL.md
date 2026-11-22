---
name: authoring
description: Use when creating or editing a skill, AGENTS.md, role, workflow, persona, template or adapter in this repository, or when asked to add or change a rule for how you work.
---

# Authoring

Your behaviour is carried by your files, so a change to one is a change to the product. Take the steps in order; each is
finished when its "Done when" holds. The writing rules, the checklist for each file type and the check commands are in
`docs/authoring.md`.

## 1. Name the observed miss

Write one sentence: what went wrong, where it is recorded (a task record, a log line, the user's correction or request),
and what should have happened. A correction or a request from the user counts, and so does a task that could not be
carried out. A guess that something might go wrong does not: a rule against a failure nobody has seen costs attention in
every session and can make that failure more likely.

Done when: the sentence exists and cites its record. If you cannot cite one, tell the user there is no observed miss and
stop here.

## 2. Find the rule's one home

A rule lives in one file, so that changing it is one edit. Pick the file whose "Owns" line in `docs/authoring.md` covers
the miss, and use the core or local check there to choose between a core file and `local/`. Then search the Laima folder
for the rule's key words.

- If a line already covers the miss, sharpen that line, or the pointer that leads to it, in place of adding a second.
- If `git log -p <file>` shows that line was already sharpened for the same miss, wording is not the fix. Tell the user
  it may need a hook or permission rule, which is theirs to decide.
- A new skill is right only for a procedure with steps that no existing skill's description covers. A fact or a rule
  goes into the instruction file that owns it.
- A change that adds a folder, script, skill or tool (a move or a rename adds none) starts as the smallest thing that
  could settle the miss: a run by hand, a paragraph in the file that owns the rule. Try that, and write what it left
  unsettled into the task record, or into the commit message when the change has no task. Build the larger thing only
  for that remainder; when nothing is left, the small thing is the change, and you tell the user so.

Done when: you can name the one file, and the search shows no other file stating the same rule. Links to it are fine.
For a change that adds one, the record or the commit message names the smallest version tried and what it left
unsettled.

## 3. For a skill: write the trigger cases

In `cases.md` beside `SKILL.md`, write at least three requests that should start the skill, in the words the user would
type, one of them without the skill's name. Add at least three near misses that should not start it, each with what
handles it instead. Other file types skip this step.

Done when: reading only the `description`, you sort every case correctly.

## 4. Draft against the checklist

Read the writing rules, the checklist for this file type and the core or local check in `docs/authoring.md`, then make
the edit. Change the lines the miss calls for and leave the others as they are: a rewrite that no miss asked for changes
behaviour nobody tested.

Done when: you have checked each item of that checklist and of the core or local check against the file, and each one
passes or is reported to the user as failing.

## 5. Test

Run the checks from the table in `docs/authoring.md` that apply to the file: an instruction file must show as loaded, a
skill as listed with its description. For a skill, also run it once on a real case. Use the miss from step 1 when it can
be repeated, in a fresh session where you can, because you wrote the text and will read into it what you meant. When the
case cannot be repeated now, the next real use is the run.

Done when: each check you ran shows what its "Passes when" column says, and for a skill the real case came out as step 1
said it should. A check you could not run, because it needs the user or costs model runs, is reported as not run.

## 6. Add or bump the `Verified:` line

A skill ends with a `Verified:` line and an adapter has a `Version checked:` line under its title, in the formats
`docs/authoring.md` gives. Other files carry neither, and an adapter's line holds only a version: the record of what was run is the commit
message, and the task record when the change has a task. For a skill, write the date from the clock and the harness
versions you tested on; take what step 5 ran off "Not yet run" and add what this change left unrun. For an adapter,
move the line to a newer version only once step 5 has checked what that version changed. The case you ran goes in the
commit message.

Done when: an adapter's line names a version whose changes step 5 checked, with no date or account of a run, and a
skill's "Not yet run" holds none of what step 5 ran and all that this change left unrun. A skill that has not yet run
on a real case says so on this line.

## 7. Commit the core change

Commit the changed core files in the Laima folder, with a message that names the miss from step 1 and the checks that
passed. Keep the commit local: publishing the core waits for the user's word. Files under `local/`, other than its
`AGENTS.md` files, are untracked and have nothing to commit. Then tell the user which file changed and why, since a
change to your own rules is otherwise invisible to them.

Done when: `git status --short` shows nothing left from this change, `git log -1` shows the commit, and the user has
been told.

Verified: 2026-11-22, Claude Code 2.1.329 to 2.1.330 and Codex 0.170.0. Not yet run: a new core skill; step 6 moving an adapter's line to a newer version.
