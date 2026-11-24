# Trigger cases: herdr

Should start the skill:

- "Open a new tab next to me running another Claude session to look at the flaky test, and tell it to report back to
  me." (in a Herdr terminal; the request never names Herdr)
- "Is the reviewer in t7 still working? Read its screen and tell me where it is."
- "Close the panes you opened for the review."
- "Ask the Codex session in t9 what it thinks of the plan and bring me its answer."
- "Make the Herdr sidebar narrower and give me a key for the next space."
- Any session where `$HC_TERMINAL_ID` is set, before it starts a helper agent in another terminal.
- (In a Herdr terminal) "Run the integration suite under my row in the agents list and give me its exit code."

Near misses, with what handles each (`$HC_TERMINAL_ID` unset in the first three):

- "Split the tmux window and tail the log in the new pane." → tmux's own commands; this skill covers Herdr only.
- "Open a new tab in the browser and check the staging page." → a browser tool; the tab is not a Herdr tab.
- "Run the tests in the background and tell me when they finish." → the harness's own background command; no other
  terminal is involved.
- (Laima, in a Herdr terminal) "Start the builder for task 2026-01-31-fix-login." → `launch` and the Herdr adapter;
  her task sessions follow them.
- (A worker in a Herdr terminal whose brief ends with the report's `hc send`) "Send your report now." → the brief's
  report block, which holds the exact command.
