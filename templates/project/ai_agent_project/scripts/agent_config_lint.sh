#!/usr/bin/env bash
# Purpose: Lint AGENTS/CLAUDE/Cursor/Windsurf rule files for required safety and handoff concepts.
# Usage: bash scripts/agent_config_lint.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/agent_config_lint.sh

Lint AGENTS/CLAUDE/Cursor/Windsurf rule files for required safety and handoff concepts.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi


log() { printf '[devos] %s
' "$*"; }
warn() { printf '[devos:warn] %s
' "$*" >&2; }
has() { command -v "$1" >/dev/null 2>&1; }
repo_root() {
  if git rev-parse --show-toplevel >/dev/null 2>&1; then git rev-parse --show-toplevel; else pwd; fi
}
copy_missing() {
  local src="$1" dst="$2"
  if [[ -e "$dst" ]]; then
    warn "exists, skip: $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  cp -R "$src" "$dst"
}



root="$(repo_root)"; cd "$root"
files=(AGENTS.md CLAUDE.md .cursorrules .windsurfrules)
required=("Verify First" "Trust Telemetry" "Git" "secret" "test" "NEXT_CODEX_PROMPT")
status=0
for f in "${files[@]}"; do
  [[ -f "$f" ]] || continue
  echo "Checking $f"
  for r in "${required[@]}"; do
    if ! grep -qi "$r" "$f"; then echo "P2 missing in $f: $r"; status=1; fi
  done
done
exit $status
