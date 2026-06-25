#!/usr/bin/env bash
# Purpose: Collect redacted project context for agent handoff into docs/PROJECT_CONTEXT_FOR_AGENT.md.
# Usage: bash scripts/collect_project_context.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/collect_project_context.sh

Collect redacted project context for agent handoff into docs/PROJECT_CONTEXT_FOR_AGENT.md.
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
out="docs/PROJECT_CONTEXT_FOR_AGENT.md"
{
  echo "# Project Context For Agent"
  echo
  echo "Generated: $(date)"
  echo "Root: $root"
  echo
  echo "## Git"
  git status --short 2>/dev/null || true
  git rev-parse --short HEAD 2>/dev/null || true
  git diff --stat 2>/dev/null || true
  echo
  echo "## Files"
  find . -path ./.git -prune -o -path './node_modules' -prune -o -path './Pods' -prune -o -path './.dart_tool' -prune -o -type f -maxdepth 4 -print | sort | sed 's#^./##'
  echo
  echo "## Notes"
  echo "Secrets, .env files, node_modules, Pods, build outputs are intentionally excluded."
} > "$out"
log "wrote $out"
