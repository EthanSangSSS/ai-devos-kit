#!/usr/bin/env bash
# Purpose: Run AI Agent project preflight checks.
# Usage: bash scripts/preflight.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/preflight.sh

Run AI Agent project preflight checks.
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
echo "Branch: $(git branch --show-current 2>/dev/null || true)"
echo "HEAD: $(git rev-parse --short HEAD 2>/dev/null || echo none)"
git diff --stat 2>/dev/null || true
[[ -d prompts ]] || echo "P1: missing prompts/"
[[ -d evals ]] || echo "P1: missing evals/"
[[ -d tests ]] || echo "P2: missing tests/"
bash scripts/agent_config_lint.sh || true
bash scripts/secret_redacted_scan.sh || true
