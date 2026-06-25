#!/usr/bin/env bash
# Purpose: Build a timestamped next Codex prompt from project risk/changelog/handoff docs.
# Usage: bash scripts/next_prompt_builder.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/next_prompt_builder.sh

Build a timestamped next Codex prompt from project risk/changelog/handoff docs.
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



root="$(repo_root)"; cd "$root"; mkdir -p docs
ts="$(date +%Y%m%d_%H%M%S)"
out="docs/NEXT_CODEX_PROMPT_$ts.md"
{
  echo "# NEXT_CODEX_PROMPT"
  echo
  echo "Goal: continue from current repo state with Verify First and Trust Telemetry."
  echo
  echo "## Current Git"
  git status --short 2>/dev/null || true
  git rev-parse --short HEAD 2>/dev/null || true
  echo
  for f in docs/KNOWN_RISKS.md docs/CHANGELOG_AGENT.md docs/NEXT_CODEX_PROMPT.md; do
    [[ -f "$f" ]] || continue
    echo "## $f"
    sed -n '1,160p' "$f"
    echo
  done
  echo "## Required Output"
  echo "current branch, HEAD, diff stat, commands run, pass/fail, remaining risks, next prompt."
} > "$out"
log "wrote $out"
