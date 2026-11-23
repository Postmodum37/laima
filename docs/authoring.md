# Authoring Laima's files

Read this before you create or edit a file that carries your behaviour: an `AGENTS.md`, `persona.md`, `local/user.md`, a
template, a role, a workflow, a skill or an adapter. The steps for making a change are in the `authoring` skill. This
file holds what a finished file must satisfy and the commands that check it.

If the `writing-for-agents` skill is installed, load it for depth on pointers, completion criteria and pruning. Where it
and this file differ, this file wins: it asks for normal volume where the skill suggests a stronger word, and it keeps
the user's own words in a skill description where the skill would merge them.

## Writing rules

- **Keep a line only if you would get it wrong without it.** Every line is read in each session that loads it, and lines
  that change nothing thin the attention left for the rest. Leave out what a look at the folder or a `--help` answers: a
  written copy goes stale, and a stale line is followed over the facts. A file is as long as this test leaves it. Size
  is checked only against what a harness cuts, which the checklists name: a line count gets met by cutting whatever is
  easiest to cut.
- **Normal volume.** Plain sentences, without capitals or intensifiers for emphasis, because current models over-apply
  an emphasised rule. A rule that cannot bend belongs in a hook or permission rule, and adding one is the user's
  decision.
- **Give the reason.** It lets you apply the rule to a case it did not foresee, and tells the next editor when the rule
  can go.
- **Point with a trigger.** A pointer names the case that sends you to the file: "for a new adapter, read
  `docs/authoring.md`". "Read X before every edit" loads X when it is not needed, and a bare link gives no reason to
  follow it.
- **Say which source wins.** Where two sources can disagree (a note and what you observe, the core persona and the
  user's additions), one file says which holds.
- **State the behaviour you want.** "Write the log line before you reply" rather than a list of things to avoid. Keep a
  ban only for a failure that has been observed, with its reason and what to do instead.
- **Wrap prose at 120 characters.** A change then shows in a diff as the lines it touched. A table row, a command, a
  frontmatter field and a `Verified:`, `Version checked:`, `Release notes:` or `Tool guide:` line each stay on one line.

## Checklists

Each file type owns one kind of content. A rule goes in the file that owns it, and other files link to it. Check every
item against the file before you save it.

### Root `AGENTS.md`

Owns what every session needs, and the routing to everything else.
- Carries in its own text: what Laima is; the files to read at start, in order; the folder map; which skill serves which
  step; the sentence that what you observe beats what a file says. Codex loads no other file at start, so nothing a
  session always needs may sit behind a link.
- The folder map gives each folder's purpose and tells you to read a folder's `AGENTS.md` before working there. No
  harness loads that file when you create a new file in the folder, so this instruction is what makes folder files
  reliable.
- One level of routing: the map marks every folder that has an `AGENTS.md`, and no folder file routes onward. `find .
  -name AGENTS.md -not -path './.git/*'` lists the root and exactly those folders.
- Other files are reached by Markdown links or plain paths. An `@file` import reaches Codex as literal text, and Claude
  Code loads a symlinked instruction file twice.
- No `CLAUDE.md`, `.claude/CLAUDE.md` or `CLAUDE.local.md` sits here or in any folder above it: `find . -name
  'CLAUDE*.md'` prints nothing, and the loop in README § Start prints nothing for the folders above. On a default
  Claude Code setup such a file is read in place of every `AGENTS.md`, which switches this tree off without a
  message; the user's own `~/.claude/CLAUDE.md` does not count.
- Holds no procedure, persona or user fact, and describes no folder beyond its one map line.
- `wc -c AGENTS.md` stays well under 24,000: past that agy cuts the file, and past 32,768 Codex does, neither
  telling you (each harness adapter § Instruction files it loads).

### Folder `AGENTS.md`

Owns the rules for writing in one folder. Only a folder you write into under rules has one.
- Covers: purpose in one line; what belongs here, and where the rest goes; naming; the template for a new item; who may
  write.
- Repeats nothing from the root. Where it needs a root rule it gives the path.
- Its folder is marked in the root's folder map.
- Holds nothing you need before deciding to enter the folder, because it loads only once you are working there.
- Under `local/` it is still a core file, so the core or local check below applies.

### `persona.md`

Owns who Laima is and how she sounds.
- Each trait is a behaviour visible in a reply ("leads with the outcome"), not an adjective.
- Says where the voice does not apply: briefs to workers, task records, log lines.
- Leaves authority, routing and procedure to the root, the workflows and the skills.
- Examples, if any, are several, varied and labelled as illustrations. A single example gets copied in length and tone.
- `local/persona.md` holds only the user's additions, not a copy of the core file.

### `local/user.md`

Owns who the user is and the user's own rules.
- One fact or directive per line, written as it holds now. A changed preference replaces its old line; history belongs
  in the log.
- Points to the user's global instruction files by path. They already load in your session, and a copy goes stale.
- Project facts go to `local/projects/`, voice adjustments to `local/persona.md`, tool and model choices to
  `local/setup.md`.
- § Notes areas lists the files and folders in the vault that are the user's own, each with what it holds and who
  writes there and how. The rule for them is `local/AGENTS.md` § The user's own notes.
- A change every user should get goes into `templates/user.md` or the core instead.

### Template

Owns the starting content of one `local/` file. Lives in `templates/`.
- `set-up` copies it once, into a vault that lacks the file, and never again. A section you add later reaches no
  existing vault, so the file that points to it is written to read a missing section as an empty one.
- Every heading a core file points to with `§` exists in the template under the same words.
- Holds headings, placeholders in `<angle brackets>` and a line on what goes under each. It is a core file, so the core
  or local check below applies.
- Holds no rule: a rule copied into a vault never changes again. It goes in the file that owns it.

### Role file

Owns what a session of one role is for and what it may change.
- Has the headings `roles/AGENTS.md` lists, and no others.
- Authority is one of the three `roles/AGENTS.md` names, in its terms.
- "Suited to" names a kind of harness and model with its reason, and no product version or model name. The concrete
  choice lives in `local/setup.md`.
- "Hands back" and "In the brief" can be lifted into a brief as written. A worker in another repository loads none of
  the Laima files, so the brief is the only way this text reaches it.

### Workflow file

Owns the path a task takes: its steps, where the user is asked, and what done means.
- Has the headings `workflows/AGENTS.md` lists.
- Has its row in the root's workflow table, under the same name as the file.
- "Use when" tells this workflow from its nearest neighbour.
- Every step names its role, or says Laima does it.
- "Done when" is a condition that facts can show (a commit, a pull request, a test result), so that a worker's word is
  not what closes the task.
- Leaves how to launch and how to finish to the skills.

### Skill

Owns the procedure for one kind of step.
- Lives at `.agents/skills/<name>/SKILL.md`, with a relative symlink `.claude/skills/<name>` to that folder. Codex scans
  `.agents/skills` and Claude Code scans `.claude/skills`. This is the only kind of symlink in the repository. A
  multiplexer's companion skill is the exception: it lives beside its adapter, with no link and no row in the Skills
  table (§ Adapter document).
- Has its row in the root's Skills table. A pointer in a file that is always loaded starts a skill more reliably than
  its description does.
- Frontmatter holds `name` (lowercase and hyphens, same as the folder) and `description`. Add another field only if
  every harness reads it the same way; the fields that control invocation differ between them.
- The `description` is a trigger. It opens with "Use when", names each distinct case in the words the user types, and
  stays under 1,024 characters: Codex shows you only that much of it. It says when to use the skill and leaves out how
  the skill works, because a summary there gets followed in place of the body.
- Every step ends on a completion criterion you can check.
- Reference that only some runs need sits in a file beside it, linked with its trigger. After a compaction Claude Code
  keeps the first 5,000 tokens of a skill's body (about 20,000 characters), so a step past that point is lost in the
  middle of a task.
- `cases.md` beside it holds at least three requests that should start the skill and three near misses that should not.
  The description alone sorts every one correctly.
- The last line is `Verified: YYYY-MM-DD, <harness> <version>. Not yet run: <what>`. Until the skill has run on a real
  case, the line says so. It names only what a session should not yet rely on: a run takes its case off the line and
  puts it in the commit message.

### Adapter document

Owns how one multiplexer or harness does what the core describes in general. A harness's adapter lives in
`adapters/harnesses/`, a multiplexer's in `adapters/multiplexers/`.
- Answers every fixed question, in order, each under a heading worded as in the other adapters, because the root and the
  skills point to an answer by its heading. Where the tool cannot do something, the answer says so: a missing answer
  reads as nothing to know.
- Multiplexer questions: starting a task session, with its tags; seeing all sessions; what waiting on the user looks
  like; how you learn a session finished, with the worker's send as one block for the brief; what you are not told;
  reading a session; messaging it; closing it; what the user is notified of without you; what to do after a reboot;
  known gotchas.
- Harness questions: launching with a brief; which instruction files it loads; finding a session's id; resuming from it;
  where transcripts live, how long they are kept and which folders the user worked in; how a worker reports back;
  reading the remaining usage; known gotchas.
- Holds instructions for using the tool: what to run, what to expect, and what to do when it goes otherwise, in the
  present tense. You read it while you work and act on each line, so it holds no date, no count of runs or tries, no
  account of a test ("in one test", "twice in six sends") and no model name except as an example value of a flag.
  Which model a role runs on is `local/setup.md`'s.
- A fact that holds only under a condition (a pairing of tools, a mode, a length) states the condition, not how it was
  found.
- Gives the exact command where one exists, and leaves option lists to the tool's own `--help`.
- A fact sits in the adapter of the tool it is about: what a harness shows, asks or keeps (its prompts, which option
  starts selected, its flags) in the harness adapter, what a multiplexer's commands do in the multiplexer's. Each points
  to the other by heading. A fact seen with only one pairing names the other tool, so that it is not read as holding
  for all: "both harnesses" turned false when a third was added.
- A fact read in documentation, `--help` or source and not run carries *(read, not run)*, so that you know to check it
  before you rely on it. A run that confirms it takes the mark off.
- Directly under the title: `Version checked: <tool> <version>`, the last version on which the answers were run or
  read, then `Release notes: <where the tool publishes its changes>`, then `Tool guide: <what the tool ships to
  explain itself>` (a `--skill` or `--help`, a built-in skill or agent). The adapter leaves to that guide what it
  holds.
- A multiplexer fact that a session outside Laima needs as well (how the tool misbehaves, not Laima's tags,
  authority, report block or records) lives once, in `adapters/multiplexers/<multiplexer>/gotchas.md`, under a
  heading that states it. The adapter points to that heading at the step where it applies, and the companion skill
  points to it too, so that one change reaches both readers. A fact only Laima needs stays in the adapter.
- A multiplexer that installs no skill of its own can have a companion skill beside its adapter,
  `adapters/multiplexers/<multiplexer>/SKILL.md`, for sessions outside Laima. It holds what neither the tool's guide
  nor `gotchas.md` holds, its description says it is not for Laima's own task steps, and it reaches its files by
  paths relative to its folder, so that it works through a global link. It follows § Skill otherwise. A user links
  it globally by choice (README § Making her yours). Rex has none: `rex skill setup` installs Rex's own, and a second
  skill named `rex` would clash with it.
- When the installed version is newer than that line, read the release notes between the two versions for a change
  under any of the headings, run the commands under the headings a change touches again, correct the answers, and move
  the line to the new version. What was run, and what it showed, goes where `authoring` step 6 puts a change's
  record, not in the adapter.

## Core or local

Everything tracked is core: every file outside `local/`, plus the five `AGENTS.md` files inside it that `.gitignore`
names. Core is written to be published; the rest of `local/` never leaves the machine. Before you save a core file:

- It names no person, employer, project or repository of the user's, and no path that exists on one machine only, such
  as a home directory or a workspace folder. Write "the user", and paths relative to the Laima folder. `grep -n -E
  '/Users/|/home/' <file>` prints nothing.
- Every line would be true for a stranger who cloned the repository. A line true only for this user moves to `local/`,
  into the file that owns it.
- Examples use invented names and IDs.
- A workflow, role or skill that only this user needs is local: `local/AGENTS.md` § The user's own workflows, roles and
  skills says where it goes. Its checklist here applies except for the lines that keep a core file generic, and a local
  skill needs no row in the root's Skills table.
- `git status --short` lists nothing under `local/` except `AGENTS.md` files.
- A change that alters what `README.md` states (the requirements, what is where, the status, what she is not) changes
  the README in the same commit. It is written for people and loads in no session, so nothing else brings a stale line
  there to light.

## Checks the harnesses ship

Run the ones that apply after an edit, from the Laima folder.

| Command | Run from | Shows | Passes when |
|-|-|-|-|
| `/context` | A Claude Code session | The instruction files and skills loaded into the session, with their token cost | The root `AGENTS.md` is listed, no `CLAUDE*.md` from the Laima folder is, and a changed skill appears |
| `/doctor prompt-audit` | A Claude Code session | An audit of everything that loads in the session, the user's global instructions, skills, agents and plugins included: emphasis, contradictions between files, leftovers, paths and commands that no longer resolve. It proposes a diff and applies nothing | Each finding on the file you changed is fixed or answered |
| `codex debug prompt-input` | A shell | As JSON, the exact input Codex gives the model, without calling one | The root `AGENTS.md` appears whole in the first user message, and a skill appears by name with its description. Folder files are absent at a root start; that is expected |
| A scenario from `docs/testing.md` | A fresh session in a throwaway copy, on the real multiplexer | What a session does with the changed file, judged against the guide's goals | Each scenario that uses the changed file passes on the model `local/setup.md` names for the role |
| `claude plugin eval <skill folder> --trust-plugin --no-publish --model <model> --runs <n> --max-cost-usd <usd>` | A shell | Runs each case under the skill's `evals/` (a folder per case with `prompt.md` and `graders/*.md`; `claude plugin eval init --bare <name>` writes a blank one) with and without the skill, and scores the difference. It writes `evals/results/` there | It exits 0: no case scored below `--threshold` |

- The two slash commands are typed by the user. Ask for them and read the result. From a shell, `claude -p "/context
  all"` prints the same tables. `/doctor prompt-audit` has the session it is typed in do the audit, and the user's
  global files make it a long run: ask for it after a change to several files. Its findings on the user's global
  files go to the user; a finding on a core file is a miss to take through the `authoring` skill.
- `claude plugin eval` starts a full model session per run on the user's account, three runs per case by default and
  again for the baseline, on the user's default model unless `--model` is given, and it publishes its report to
  claude.ai unless `--no-publish` is given. Run it when the user asks for it. No skill in the core has cases in its
  format yet.
