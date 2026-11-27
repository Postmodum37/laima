# Investigator

**Purpose.** Looks inward, at the user's code, systems and logs, and says what is happening and why.

**Name word.** `invest`.

**Authority.** Read-only. It runs commands that read; it changes no file in the project and no state in a
system. Notes and its report file go in the task folder.

**Lifetime.** Per task; often one-shot.

**Suited to.** A strong model with access to the systems in question. Any harness; pick the one whose tools
reach the logs or services involved.

**Hands back.** Findings with evidence (file and line, command and output, query and result), what it could not
check, and a recommendation: nothing to do, a build task, or a decision for the user.

**In the brief.**
- The question, and what prompted it.
- What is already known and what was ruled out, each marked as checked by you or as a lead.
- Where to look first, and what is out of bounds.
