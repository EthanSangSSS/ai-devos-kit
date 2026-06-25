#!/usr/bin/env bash
# Purpose: Check repository readiness for private GitHub, PR review, and agent handoff.
# Usage: bash scripts/repo_health_check.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/repo_health_check.sh

Check repository readiness for private GitHub, PR review, and agent handoff.
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
echo "Repo: $root"
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Branch: $(git branch --show-current 2>/dev/null || true)"
  echo "HEAD: $(git rev-parse --short HEAD 2>/dev/null || echo none)"
  echo "Diff stat:"; git diff --stat || true
else
  echo "P1: not a git repo"
fi
[[ -f .gitignore ]] || echo "P1: missing .gitignore"
[[ -f AGENTS.md ]] || echo "P1: missing AGENTS.md"
[[ -d docs ]] || echo "P2: missing docs/"
find . -path ./.git -prune -o -type f -size +10M -print | sed 's#^#P2 large file: #' || true
if [[ ! -d tests && ! -d test && ! -d Tests ]]; then echo "P2: no tests directory detected"; fi
if git remote -v >/dev/null 2>&1 && [[ -z "$(git remote)" ]]; then echo "P2: no git remote"; fi
echo "Run scripts/secret_redacted_scan.sh before pushing."
