#!/usr/bin/env bash
# Explicit handoff producer; never called as a mandatory task footer.
set -euo pipefail
if [[ "${1:-}" == --help || "${1:-}" == -h ]]; then
  echo 'Usage: bash scripts/next_prompt_builder.sh [bounded next acceptance target]'; exit 0
fi
if [[ -z "${1:-}" ]]; then echo 'NEXT_ACTION=NONE'; exit 0; fi
unset GIT_DIR GIT_WORK_TREE GIT_COMMON_DIR
root="$(git rev-parse --show-toplevel)"
printf '%s\n' '/goal' "Goal: $1" 'REVALIDATE_FIRST=true' 'Prior handoff = CLAIM / CONTEXT' "Workspace: $root"
printf 'Branch: '; git -C "$root" branch --show-current
printf 'HEAD: '; git -C "$root" rev-parse HEAD
git -C "$root" status --short
printf '%s\n' 'Authority: inherit explicit task authorization only.' 'Validation: re-read filesystem, Git, GitHub/PR and runtime; run relevant checks.' 'Stop: identity/scope/authority drift or ambiguous external result.' 'Final evidence: changes, exact identity, validation, risks, NEXT_ACTION.'
