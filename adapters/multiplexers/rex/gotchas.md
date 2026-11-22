# Rex gotchas

Facts about Rex that both Laima's task steps and a session working with Rex on its own have to know. Each has its
own heading, so that the Rex adapter can point to it where it applies. Rex's own guide, `rex skill show` (installed
for agents by `rex skill setup`), holds the general use, and this file only what it leaves out. Rex has no companion
skill in Laima, since a second skill named `rex` would clash with the one Rex installs.

## Outside Rex's terminals `rex` is not on the PATH

`rex` is on the PATH only in Rex's own terminals; elsewhere it is
`~/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex`.
The path holds spaces: put it in double quotes.

## A block outside your own Rex session needs `-s`

Every command that names a block outside the caller's own Rex session needs `-s <session-id>` with it: without it a
full block id is answered `block target … not found`. So whoever is to reach your block needs both of your ids,
`$REX_SESSION` and `$REX_BLOCK`, which `rex whoami --json` confirms.

## A subagent inside your harness acts as you

A subagent or teammate inside your own harness inherits `$REX_SESSION` and `$REX_BLOCK`: its `rex` commands act as
you, and its status shows as a second record on your block.

## A send types after any draft at the prompt

`rex send` types into a block's input as it stands: a draft left unsent there is submitted in front of the sent
text, as one message. Text before the sent text is the person's: give it back to them.

## `rex skill setup` makes Codex stop at Hooks need review

`rex skill setup` adds a start hook to Claude Code and to Codex. Codex then opens "Hooks need review" at every
launch until the user trusts the hook, and that prompt reports no status. It is the user's to answer: ask them to
trust it once, or a Codex session sits there unseen.

## An app setting action without a value changes the setting

An app setting action called without a value toggles it or moves to the next choice (`rex -C <client> actions
--json` gives each action's arguments). To read the Mac app's settings without changing them, use `defaults read
com.superlogical.rex`.

## `rex --version` is refused

`rex --version` is refused as an unknown flag; the version is `rex version`.
