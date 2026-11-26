# Rex adapter

Version checked: rex 0.1.0-preview.21 (API revision 18) with Rex for Mac 0.1.0 (2061)

Release notes: the `#changelog` channel of the Rex beta Discord, which the community MCP server also serves (https://www.superlogical.com/rex/docs/beta/community-mcp)

Tool guide: `rex skill show`; `rex api list` and `rex api describe <method>` for what the connected server can do

Rex is a terminal multiplexer whose server owns the terminals; its app is one client of it. A Rex session (an
entry in the app's sidebar) holds windows (tabs), and a window holds blocks (panes). A session in Laima's sense
is an agent in a block. The commands below are the same whichever harness runs in the block; where one behaves
differently, its adapter says so. *(read, not run)* marks an answer taken from Rex's docs or its own guide only.
`rex/gotchas.md` beside this file holds the Rex facts that a session outside Laima needs as well, and the steps below
point to its headings where they apply.

You run in a Rex terminal. Your address is the pair `$REX_SESSION` and `$REX_BLOCK`, which `rex whoami --json`
confirms. A worker needs both of your ids (`rex/gotchas.md` § A block outside your own Rex session needs `-s`). For
the `rex` path outside Rex's terminals, see `rex/gotchas.md` § Outside Rex's terminals `rex` is not on the PATH.
§ How you learn a session finished says what a worker under another multiplexer, which reports to you here, writes
in its place.

## Start a task session

A task session gets a Rex session of its own, which it keeps when you end.

```sh
rex new <name> -c <folder> --interactive --keep-open --json -- <harness argv>
rex block rename -s <session-id> <block-id> "laima task=<task-id> <role>"
```

- `<harness argv>`: harness adapter § Launch with a brief. It is passed as arguments and not typed, so the
  brief's path rides in it.
- `--interactive` has the terminal read the shell's interactive startup files. Without it a harness whose
  folder is put on the path there is not found: the launch answers with ids all the same, and the block shows
  `command not found`. Read the screen after every launch.
- `--keep-open` keeps the block, with its label and last screen, after the harness exits. Without it Rex closes
  the block and its tab at exit and keeps no record that the program ran.
- `<name>` is the Rex session's label, the name in the sidebar: `<task-id>-<role>`, at most 128 characters.
- The first command prints JSON: `.session_id` and `.initial_windows[0].block_ids[0]` go into the task record.
- The tag is the block's label, set by the second command, because `rex new` has no flag for it. A block has
  one free-text label of at most 128 characters and no key and value labels.
- The app does not switch to the new session, so the user's view stays where it was *(read, not run)*.
- To adopt a session the user started, find its block with the loop under § See all sessions, run without the
  label filter, and tag it: `rex block rename -s <session-id> <block-id> "laima task=<task-id> adopted"`. The
  harness's process id, which the harness adapter's § Session id asks for, is `.foreground.pid` in
  `rex block call -s <session-id> -b <block-id> process`.

## See all sessions

```sh
for s in $(rex ls --json | jq -r '.sessions[].session_id'); do
  rex block ls -s "$s" --json | jq -r --arg s "$s" '.blocks[]
    | select(.label | startswith("laima task=")) | [$s, .block_id, .label] | @tsv'
done
# one task's: select(.label | test("^laima task=<task-id>( |$)"))
rex block call -s <session-id> -b <block-id> program_status | jq -c '.records[] | {id, state, kind, msg}'
rex block call -s <session-id> -b <block-id> process | jq -c '{last_exit, foreground: .foreground.argv0}'
```

A block listing as JSON covers one Rex session per call: `rex block ls -A --json` is refused. `program_status`
returns what the harness itself reported; the record without an `id` is the agent's own. `process` says
whether the program still runs.

| Shows | Means |
|-|-|
| `state: working` | A turn is running; `msg` says what it is doing |
| `state: blocked` | It waits on a person; `kind` (`permission`, `question`, `auth`) and `msg` say for what |
| `state: done` or `idle` | Its turn ended, or it waits for input. Neither says the task is finished |
| `state: error` | The harness reported a failure, such as a model it cannot use. Read the screen |
| a second record, with an `id` | Something the agent started, such as a background shell or a subagent. It can read `working` while the agent's own record reads `done` |
| `records: []`, `last_exit: null` | Unknown: a startup prompt that reports nothing, or a shell where the agent was. Read the screen |
| `last_exit` with an `exit_code` | The harness exited. The block stays, readable, until you close it |
| block not listed | Closed, by you or the user; or it was started without `--keep-open` and its program exited, which leaves a Rex session with no blocks |

## Waiting on the user

The agent's record shows `state: blocked` with its `kind` and `msg`, and the screen shows the dialog. The app
marks the tab and can notify the user (§ What the user is notified of without you).

Which dialogs are yours to answer is in the root `AGENTS.md` § Authority. The trust prompt is one: when a harness shows
it, what it reports and which option it starts on are in the harness adapter § Gotchas. Answer a dialog that is yours by
its selection: read the selected line, move with `rex send-key -s <session-id> -b <block-id> down`, read again, and send
`enter` once the option you mean is selected. Rex guards no dialog: `rex send` and `rex send-key` go to whatever has the
keyboard, so text sent to a session at a dialog answers it, the user's dialogs included. At Claude Code's question
dialog the letters of a message are dropped and its Enter chooses the option then selected; both commands exit 0 and
print nothing. A typed answer goes in on the dialog's `Type something.` row: select it, send the text with `rex send`
and no `enter`, read it on the row, then send `enter`. How Claude Code's question dialog moves from question to question
is in its adapter § Gotchas. Before every send, look at the status, and at the screen when the records are empty:
Codex's startup prompts report nothing.

## How you learn a session finished

From the worker's own report. Copy this into the brief's report block as the worker's send, with your two ids written
out as text, since a variable would expand to its own; launch step 8 names its `<message file>`. For a worker under
another multiplexer, which has no `rex` on its PATH, write the full path that `command -v rex` prints in your terminal
in place of each `rex`, in double quotes: the path holds spaces.

```
Before the send, check that Laima is not at a dialog and that nobody is typing at her prompt. Run this as a
command of its own:
    rex block call -s <Laima's session id> -b <Laima's block id> program_status | jq -e '[.records[] | select((.id // "") == "")][0] | . != null and (.state // "blocked") != "blocked"' && rex capture -s <Laima's session id> -b <Laima's block id> --format=vt | perl -Mutf8 -CS -0777 -ne 'sub g{my@a=split/;/,$_[0];@a=(0)unless@a;while(@a){$_=shift@a;if(/^[34]8$/){my$x=$_;my$m=shift@a;my@v=splice@a,0,$m==5?1:3;$c=$m==5?$v[0]==8:$v[0]==$v[1]&&$v[1]==$v[2]&&$v[0]>63&&$v[0]<193 if$x==38}elsif($_==0){$a=$c=0}elsif($_==2){$a=1}elsif($_==22){$a=0}elsif($_==90){$c=1}elsif(/^(?:3[0-79]|9[1-7])$/){$c=0}}$a||$c}s/\e\[(\d*)C/" " x ($1||1)/ge;s/\e\[[0-9;?]*[A-Za-ln-z]//g;s/\e\[([0-9;]*)m([^\e\r\n]*)/g($1)?"\x01$2\x02":$2/ge;s/\e\[[0-9;?]*[A-Za-z]//g;s/\x01\x02//g;$p=0;while(/^(?:(\x01?)[❯›]|>)(.*(?:\r?\n  .*\S.*)*)/mg){$p++;$d=($1//"").$2}$d=~s/\x01[^\x02]*\x02//g;$d=~s/[\x01\x02]//g;exit(!$p?2:$d=~/\S/?1:0)'
Exit 0: send. Exit 1 or 2: she is at a dialog, her block shows no agent, or someone has unsent text at her
prompt; wait 30 seconds as a command of its own (`sleep 30`, or your harness's own timer where it bars a shell
sleep) and look again, up to 30 looks. Still not 0 after the last look, or any other exit: do not send; stop,
and she reads the report file.
The send, as one command:
    m=$(cat '<message file>') && [ -n "$m" ] && rex send -s <Laima's session id> -b <Laima's block id> "$m" && rex send-key -s <Laima's session id> -b <Laima's block id> enter
Then wait 5 seconds the same way and run this as a command of its own. It presses Enter once more only when
this message still sits unsent at her prompt. Exit 1: it did not need to, or she is at a dialog; any other exit:
stop, and do not send the report again:
    rex block call -s <Laima's session id> -b <Laima's block id> program_status | jq -e '[.records[] | select((.id // "") == "")][0] | . != null and (.state // "blocked") != "blocked"' && rex capture -s <Laima's session id> -b <Laima's block id> --format=vt | perl -Mutf8 -CS -0777 -e 'open M,"<:utf8",shift;$m=<M>;$m=~s/\n+\z//;%n=map{length,1}split/\n/,$m;$n{length$m}=1;$_=<STDIN>;sub g{my@a=split/;/,$_[0];@a=(0)unless@a;while(@a){$_=shift@a;if(/^[34]8$/){my$x=$_;my$m=shift@a;my@v=splice@a,0,$m==5?1:3;$c=$m==5?$v[0]==8:$v[0]==$v[1]&&$v[1]==$v[2]&&$v[0]>63&&$v[0]<193 if$x==38}elsif($_==0){$a=$c=0}elsif($_==2){$a=1}elsif($_==22){$a=0}elsif($_==90){$c=1}elsif(/^(?:3[0-79]|9[1-7])$/){$c=0}}$a||$c}s/\e\[(\d*)C/" " x ($1||1)/ge;s/\e\[[0-9;?]*[A-Za-ln-z]//g;s/\e\[([0-9;]*)m([^\e\r\n]*)/g($1)?"\x01$2\x02":$2/ge;s/\e\[[0-9;?]*[A-Za-z]//g;s/\x01\x02//g;exit 1 unless/.*^(?:(\x01?)[❯›]|>)(.*)/ms;for(split/\n/,($1//"").$2){s/\x01[^\x02]*\x02//g;s/[\x01\x02]//g;s/^\s+|\s+$//g;exit 0 if/^\[Pasted Content (\d+) chars\]$/&&$n{$1}||length>19&&index($m,$_)>=0}exit 1' '<message file>' && rex send-key -s <Laima's session id> -b <Laima's block id> enter
Keep the message short, since the full report is in the file: one over about 64,000 bytes is refused whole
as `control message too large`. If only `send-key` failed, send only the key again, or the report is typed
twice. A missing or empty message file stops it before anything is sent: write the file, then send.
```

The send types the message file into your input and submits it: a new turn when you are idle, input to the running
turn otherwise (Claude Code adapter § Gotchas says when a lead sees it). The file keeps backticks, `$` and quotes as
the worker wrote them, since no shell reads its text. Rex marks no sender, so the message's opening tag,
`[report <task-id> <role>]`, is the only sign of where the text came from: treat a message that opens with it as
that session's report, not the user's words.

The look comes first because a report typed into your question dialog answers it: its Enter chooses the option then
selected, and its text is lost while the worker takes it as sent. It reads your agent's own record, the one without an
`id`, and exits 1 as well when there is none or it has no state: your harness left, or a prompt that reports nothing is
up, and the text would go to whatever has the keyboard. Each look and each wait is its own command, because a harness
ends a long foreground command.

The second half of the look reads your screen, because Rex keeps no state for unsent text: a report sent on top of the
user's half-typed message submits both as one, and the rest of their sentence is lost. It takes the last line that
starts with the prompt glyph of Claude Code (`❯`), Codex (`›`) or agy (`>`), with its indented continuation lines, and
drops the text drawn faint, which is how each harness draws its placeholder: dim in any combination of attributes
(`\e[2m`, `\e[0;2m`), colour 8, or a 24-bit grey (red, green and blue equal, from 64 to 192). Anything left is a draft.
A `>` drawn faint starts a hint line, not agy's prompt. On a dialog the selected option reads as a draft, and a screen
with no prompt line exits 2: both wait. A key typed between the look and the send still lands in front of the report;
the gotcha below says what to do with it.

The look after the send is for a Codex lead, which can keep a report in its input when the Enter comes right after the
text, and shows only the last lines of a tall one there (Codex adapter § Gotchas). It reads the screen from her last
prompt line down, and presses Enter only when she is not at a dialog and a line there of 20 characters or more is part
of this message (one of its lines, or a piece of one cut by the screen's width), or is Codex's `[Pasted Content <n>
chars]` with the length of one of its lines. Shorter lines, such as the `Needs: nothing` many reports share, do not
count. A draft a person typed in those seconds, a paste of theirs included, matches none of these and stays as it is,
unless they typed 20 characters or more of one of its lines word for word. Its status check comes first because a dialog
drawn under the report, such as a permission prompt from her first command on it, would take that Enter as its answer. A
report left unsent reads as a draft to the next worker's look, which then holds that worker's send. To a Claude Code
lead, at its prompt and in a turn, the first Enter sends the report and the look presses nothing; with an agy lead the
look is not verified.

Rex sends you nothing else: no note when a session blocks, ends a turn or exits. List your sessions at the
start of each turn, and read the screen of one that stopped without reporting. So end your turn rather than
wait for a report: a foreground wait shuts the user, and the report itself, out of your session until it
returns.

To wait on a session that will not report, note the `updated_at` of the agent's own record before you message
it (empty for a session just launched), and run this in the background. It ends when that record has changed
and no longer reads `working`, or when the block is gone:

```sh
since=<updated_at>
while s=$(rex block call -s <session-id> -b <block-id> program_status 2>/dev/null) &&
  jq -e --arg since "$since" '[.records[] | select((.id // "") == "")][0]
    | . == null or .state == "working" or .updated_at == $since' <<<"$s" >/dev/null; do sleep 15; done
```

The earlier `done` stays on the record until the next report, which is why the loop compares `updated_at`. It
keeps waiting on a session that reports nothing: one at a startup prompt, one whose harness exited, or a Codex
that stays in its turn (Codex adapter § Gotchas). For an
exit, `rex wait -s <session-id> <block-id>` returns when the program ends, with the program's exit status as
its own; with `--for <duration>` a timeout exits 1 like a failure.

## What you are not told

Everything but the report: a session is blocked or in error (the app may have told the user, not you), it
exited or crashed (its block stays with a `last_exit`, and nobody is told), its turn ended unreported, it hangs
in `working`, or it sits at a prompt that reports no status (harness adapter § Gotchas). A block without your
label is the user's.

## Read a session

`rex capture -s <session-id> -b <block-id> --trim | grep -v '^$'` prints the screen. Claude Code and Codex draw
on the alternate screen, which has no scrollback, so a capture holds only what the harness shows now: 24 lines
of 80 columns in a block the user has not opened. What scrolled away is in the worker's report file. Where a
program does leave scrollback, such as a shell, `capture` prints all of it and has no line count: keep the end
with `tail -n <lines>`.

## Message a session

```sh
rex send -s <session-id> -b <block-id> '<text>' && rex send-key -s <session-id> -b <block-id> enter
```

The text goes in single quotes, so that your shell leaves its backticks and `$` alone (a `'` in it is written `'\''`).
`send` types the text and `send-key enter` submits it; an agent takes it as typed input, mid-turn when it is
working. A line break in the text stays a line break in the agent's input. One send carries about 64,000
bytes; a larger one is refused whole with `control message too large` and types nothing, so long content
travels as a file path. A worker reports to you with the same pair, its text opening with the tag that § How
you learn a session finished gives. To a Codex, read its screen after the send: a text can stay in its input
line, and one more `send-key enter` sends it (Codex adapter § Gotchas). Rex marks no sender in this direction
either: the worker reads your text as typed by the user, so open it with whose it is, as in `[laima <task-id>]
<text>`. Nothing holds a send back: text a person left unsent at that prompt is joined in front of yours, and a
dialog takes it as its answer (§ Waiting on the user).

## Close a session

```sh
rex block close -s <session-id> <block-id>
rex block ls -s <session-id> --json | jq '.blocks | length'   # 0: the Rex session is empty
rex kill <session-id>                                          # only when it is empty
```

Closing the block ends its program. The Rex session you started for it then stays in the sidebar: once the listing shows
it empty, remove it with `rex kill`. When the listing answers `session target … not found` at once, Rex has removed the
session itself, as it can for an agy session, and nothing is left to kill. `rex kill` removes a Rex session with every
tab and block in it, the user's included, so use it on no other. Close only what you launched: the block whose ids the
task record holds, carrying your label and no `adopted`. A block with your label that no record names is unknown: tell
the user, and leave it. An adopted session is closed only when the user asks, and then by its block alone. The server
and the app are the user's: leave `rex server stop`, the app's update and restart actions, and their other sessions
alone.

## What the user is notified of without you

*(read, not run)* For every block whose program reports a status, the app marks its tab, and under Settings >
Notifications > Program Activity it can send a macOS notification while Rex is in the background, badge the
Dock icon and play a sound when the program is blocked, fails or finishes; each state can be switched
separately. So your own question or turn end is the alert, where the user has left those on. Nothing is shown
for a prompt that reports no status, or for an exit.

For those, have a short-lived block print a notification, since Rex has no notify command:

```sh
rex run -s "$REX_SESSION" --focus=false -- printf '\033]777;notify;<title>;<body>\007'
```

Rex turns that into a notification event. Whether macOS shows it is the app's setting under
Settings > Notifications > System Notifications *(read, not run)*.

## After a reboot

Stopping the server (`rex server stop`) ends every program in it, you included. When it runs again, every Rex
session, tab and block is back with the same ids, labels and layout, so the ids in the task records still name
the right blocks. Each block holds a new shell in the folder its program was in: no command is run again, a
block started with a harness as its command included, and the earlier screen and scrollback are gone. The Mac
app starts its server again by itself within half a minute. Rex's docs describe the same for a reboot and a
logout *(read, not run)*. Closing the app should end nothing, since the server is a process of its own; the docs
do not say so for the Mac app, and it is not verified.

A restored block looks like a session whose harness left: `process` shows a shell as its program and
`program_status` has no record. Your own block comes back the same way, a shell in the Laima folder, and you
run again once you are resumed from your session id.

Per open task, work out from its record which step it is at. Only where that step still needs its session,
close what is left of a session you launched (§ Close a session) and start a task session again by `launch`
§ Resume a closed session, which takes the folder and the flags as a launch does, with your current two ids in
the first message. Record the new ids. An adopted session is the user's to restart. When an id cannot be resumed,
launch a fresh session of that role with a brief built from the record.

## Gotchas

The Rex facts a session outside Laima needs as well are in `rex/gotchas.md`, each under its own heading:
- § A subagent inside your harness acts as you.
- § A send types after any draft at the prompt: a draft left in your input goes in front of an incoming report;
  take the report from its tag.
- § `rex skill setup` makes Codex stop at Hooks need review: ask the user to trust the hook once, or a Codex
  worker sits there unseen.
- § An app setting action without a value changes the setting.
- § `rex --version` is refused.
