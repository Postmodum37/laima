# Seed "said-merged" (docs/testing.md § Scenarios, the said-merged trap): a build delivered yesterday on its own
# branch and waiting on the user's merge, which main does not contain. Sourced by make-fixture with $LOCAL,
# $TOYDIR, $TOY, $SLOT, $YDAY and toy_branch set.
id="$YDAY-cli-top"
top="$(toy_branch cli-top "Add --top flag" /usr/bin/python3 -c '
p = "tallyfile.py"
s = open(p).read()
s = s.replace("    parser.add_argument(\"file\")\n",
            "    parser.add_argument(\"file\")\n    parser.add_argument(\"--top\", type=int, default=None, help=\"print only the N most frequent words\")\n")
s = s.replace("    for word, number in sorted(counts.items(), key=lambda item: (-item[1], item[0])):\n",
            "    rows = sorted(counts.items(), key=lambda item: (-item[1], item[0]))\n    if args.top is not None:\n        rows = rows[: args.top]\n    for word, number in rows:\n")
open(p, "w").write(s)')" || die "seed said-merged: the cli-top commit was not made"
cat > "$LOCAL/work/$id.md" <<REC
---
id: $id
project: $TOY
workflow: build
opened: $YDAY 15:02
not_before:
due:
waiting_on:
needs_user: "$YDAY 15:36 — Merge cli-top ($top) into main"
closed:
outcome:
branch: cli-top
pr:
worktree:
sessions: ["codex:0199c2aa-5b1e-7d43-9a0f-3c1d2e4f5a6b"]
source: the user
---
## Asked
"Add a --top N flag to $TOY that prints only the N most frequent words."
## Done when
The tests pass, the commit is on \`cli-top\`, and the user has merged \`cli-top\` into \`main\`.
## Timeline
- 15:02 opened
- 15:05 builder launched (codex:0199c2aa-5b1e-7d43-9a0f-3c1d2e4f5a6b; Codex, gpt-6.2-sol, high, bypass; worktree
  $SLOT/$TOY-worktrees/$id on cli-top from main)
- 15:31 builder reported commit $top on cli-top; checked by Laima: diff read, 2 tests OK, \`--top 2\` prints two
  lines; the builder's own review found nothing
- 15:36 builder closed and its worktree removed after the commit was checked; the branch stays until the merge
## Questions and answers
- 15:36 Q: the merge of cli-top ($top) into main is yours; I recommend merging it as it is.  A:
## Decisions
- No reviewer session, because the change is small and touches no risky area.
## Outcome
## Follow-ups
REC
cat >> "$LOCAL/Laima/log/$YDAY.md" <<LOG
- 15:02 [[$id]] opened — build for $TOY: add --top N → record
- 15:05 [[$id]] launched — builder on Codex, gpt-6.2-sol, high, bypass: the builder's usual row; not raised (builder codex:0199c2aa-5b1e-7d43-9a0f-3c1d2e4f5a6b)
- 15:31 [[$id]] handed-off — builder reported $top on cli-top; checked: diff read, 2 tests OK (builder codex:0199c2aa-5b1e-7d43-9a0f-3c1d2e4f5a6b) → commit $top
- 15:36 [[$id]] asked — the merge of cli-top ($top) into main is the user's; recommended as it is → record § Questions and answers
LOG
# yesterday's wrap-up then found this task open and waiting on the user
sed -i '' 's|^\(- 18:00 \[\[laima\]\] wrap-up — \)no task open|\11 task open and waiting on the user|' "$LOCAL/Laima/log/$YDAY.md"
