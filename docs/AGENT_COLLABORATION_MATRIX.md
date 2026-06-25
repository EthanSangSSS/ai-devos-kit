# Agent Collaboration Matrix

| Tool | Best for | Not for | Input | Output | Verification | Cost control |
| --- | --- | --- | --- | --- | --- | --- |
| ChatGPT Web | strategy, PR review, prompt generation | local file writes | PR URL/context | findings/prompt | Codex verifies diff | use before Codex |
| Codex | local fixes, tests, commits | blind broad scans | repo/path/logs | patch/evidence | commands/tests | narrow scope |
| Claude Code | large UI/refactor | unchecked secrets/signing | task packet | diff | tests/diff stat | staged work |
| Gemini CLI / Agy | long context batch scan | secrets/destructive actions | tight prompt | JSON/findings | smallest sample | delegate first pass |
| Local MLX | cheap drafts/log summaries | authoritative claims | local text | draft | human/Codex verify | offline |
| Computer Use | visual QA | default acceptance | simulator app | screenshots/bugs | repro matrix | only when requested |
