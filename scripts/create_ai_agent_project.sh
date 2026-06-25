#!/usr/bin/env bash
# Purpose: Create an AI Agent project scaffold with runbook, eval, security, and agent handoff files.
# Usage: bash scripts/create_ai_agent_project.sh <project_name>
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/create_ai_agent_project.sh <project_name>

Create an AI Agent project scaffold with runbook, eval, security, and agent handoff files.
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



if [[ $# -ne 1 ]]; then usage; exit 2; fi
project_name="$1"
kit_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -e "$project_name" ]]; then warn "target exists: $project_name"; exit 1; fi
mkdir -p "$project_name"
cd "$project_name"
cp "$kit_root/templates/project/ai_agent_project/AGENTS.md" ./AGENTS.md
cp "$kit_root/templates/project/ai_agent_project/README.template.md" ./README.md
mkdir -p docs scripts .github prompts evals tests
cp -R "$kit_root/templates/project/ai_agent_project/docs/." docs/
cp -R "$kit_root/templates/project/ai_agent_project/scripts/." scripts/
cp -R "$kit_root/templates/project/ai_agent_project/github/." .github/
chmod +x scripts/*.sh || true
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then git init; fi
git add .
if ! git diff --cached --quiet; then git commit -m "Initialize AI agent project with AI DevOS Kit"; fi
log "next: define tool contracts, prompt versions, eval cases, and security policy"
