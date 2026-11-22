# Trigger cases: cmux

Each case assumes a session running in a cmux terminal (`$CMUX_WORKSPACE_ID` is set), unless it says otherwise.

Should start the skill:

- "Start a Codex session in a new workspace to review this branch."
- "What is the agent in the other workspace doing right now?"
- "Tell the builder in workspace 4 that the fix is merged."
- "Is the reviewer done, or is it waiting on me?"
- "Close the workspaces you opened for this."
- "`cmux workspace close` answers confirmation_required. What now?" (outside a cmux terminal; the user names cmux)
- "Ping me when the test run in the side pane ends."

Near misses, with what handles each:

- "Open the docs page in the cmux browser pane and click Sign in." → `cmux --skill` and `cmux browser --help`.
- "Change the cmux theme and the font size." → Ghostty's config and `cmux themes`, as `cmux --help` says.
- "Run this agent on a cmux cloud machine." → `cmux cloud guide`.
- "Search the repository with a subagent." → the harness's own subagent tool; no multiplexer is involved.
- "Split the tmux window and run the tests there." (no `$CMUX_WORKSPACE_ID`) → tmux, or the skill for the
  multiplexer that is in use.
- (Laima, in a cmux terminal) "Start the reviewer for task 2026-01-31-fix-login." → `launch` and the cmux adapter;
  her task sessions follow them.
- (A worker in a cmux terminal whose brief ends with the report's `cmux agent message`) "Send your report now." →
  the brief's report block, which holds the exact command.
