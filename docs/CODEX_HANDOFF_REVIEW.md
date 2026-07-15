# Codex Handoff Review

Use this checklist when preparing `ai-devos-kit` changes for local Codex review.

## Required context

Provide Codex with:

- repository path;
- branch;
- expected remote HEAD;
- allowed files;
- forbidden actions;
- validation commands;
- stop conditions;
- final output format.

## Minimum prompt skeleton

```text
/goal
Repository: EthanSangSSS/ai-devos-kit
Local path: /path/to/ai-devos-kit
Branch: main
Expected origin/main: <sha>
Task: Review public OSS workflow readiness and sync local checkout.

Version-sync gate:
1. git fetch origin
2. git status --short
3. git branch --show-current
4. git rev-parse HEAD
5. git rev-parse origin/main
6. If dirty, wrong branch, or unable to fast-forward, stop.

Validation commands:
- python3 scripts/check_public_safety.py
- git diff --check
- git status --short

Forbidden actions:
- Do not rewrite history.
- Do not force-push.
- Do not add secrets, private source, local logs, or private user paths.
- Do not claim tests passed unless commands actually ran.

Final output:
1. Verdict
2. Starting / final HEAD
3. Files checked
4. Exact validation outputs
5. Risks / limitations
6. Follow-up required
```
