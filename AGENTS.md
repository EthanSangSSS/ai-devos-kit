# AI DevOS Kit Agent Rules

This repository is the source kit for reusable project standards. Keep changes scoped to the kit itself.

## Required Behavior

- Verify First: confirm `pwd`, branch, HEAD, diff stat, and target file paths before editing.
- Trust Telemetry: command output wins over assumptions.
- Assume Isolation: do not assume another app, simulator, shell, or repo shares this state.
- Secret redaction: never output complete tokens, API keys, private keys, signing secrets, or account credentials.
- No destructive changes: do not delete generated templates, assets, docs, or scripts unless the user explicitly asks.
- Test-before-claim: run the narrowest relevant validation before claiming completion.

## Validation

For kit changes, run:

```bash
bash -n scripts/*.sh templates/project/flutter_ios/scripts/*.sh templates/project/swift_ios/scripts/*.sh templates/project/ai_agent_project/scripts/*.sh
for s in scripts/*.sh templates/project/flutter_ios/scripts/*.sh templates/project/swift_ios/scripts/*.sh templates/project/ai_agent_project/scripts/*.sh; do bash "$s" --help >/dev/null; done
rg -n "Placeholder[ ]content|TODO:[ ]implement script logic" . --glob '!**/.git/**'
```

Every final handoff should include branch, HEAD, diff stat, commands run, pass/fail, remaining risks, and NEXT_CODEX_PROMPT.
