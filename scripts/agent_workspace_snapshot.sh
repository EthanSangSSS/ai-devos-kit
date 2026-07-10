#!/usr/bin/env bash
# Purpose: Generate a lightweight filesystem-style agent workspace snapshot for the current repo.
# Usage: bash scripts/agent_workspace_snapshot.sh
# Risk: Low. Non-destructive; writes only under .agent/ in the current git repo.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/agent_workspace_snapshot.sh

Generate .agent/current_state.md, .agent/catalog.json, .agent/handoffs/NEXT_AGENT_PROMPT.md,
and .agent/telemetry/snapshot_<timestamp>.json for the current git repository.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

log() { printf '[agent-workspace] %s\n' "$*"; }
warn() { printf '[agent-workspace:warn] %s\n' "$*" >&2; }
has() { command -v "$1" >/dev/null 2>&1; }

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

json_escape() {
  # Minimal JSON string escaping for bash-generated metadata.
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

redact_remote() {
  sed -E \
    -e 's#(https://)[^/@]+@#\1***@#g' \
    -e 's#(x-access-token:)[^@]+@#\1***@#g' \
    -e 's#(ghp_|github_pat_)[A-Za-z0-9_]+#\1***#g'
}

require_git_repo() {
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "P1: not inside a git repository" >&2
    exit 1
  fi
}

detect_project_type() {
  if [[ -f pubspec.yaml ]]; then
    echo "flutter_or_dart"
  elif compgen -G "*.xcodeproj" >/dev/null || compgen -G "*.xcworkspace" >/dev/null; then
    echo "apple_xcode"
  elif [[ -f Package.swift ]]; then
    echo "swift_package"
  elif [[ -f pyproject.toml || -f setup.py ]]; then
    echo "python"
  elif [[ -f package.json ]]; then
    echo "node"
  elif [[ -f SKILL.md ]]; then
    echo "agent_skill"
  else
    echo "generic"
  fi
}

suggest_validation_commands() {
  local project_type="$1"
  case "$project_type" in
    flutter_or_dart)
      printf '%s\n' \
        "dart format --set-exit-if-changed ." \
        "flutter analyze" \
        "flutter test" \
        "git diff --check"
      ;;
    apple_xcode)
      printf '%s\n' \
        "xcodebuild -list" \
        "git diff --check"
      ;;
    swift_package)
      printf '%s\n' \
        "swift test" \
        "git diff --check"
      ;;
    python)
      printf '%s\n' \
        "python -m compileall ." \
        "pytest" \
        "git diff --check"
      ;;
    node)
      printf '%s\n' \
        "npm test" \
        "git diff --check"
      ;;
    agent_skill)
      printf '%s\n' \
        "bash tests/validate.sh" \
        "git diff --check"
      ;;
    *)
      printf '%s\n' \
        "git diff --check"
      ;;
  esac
}

find_entrypoints() {
  find . \
    \( -path './.git' -o -path './.agent/runs' -o -path './.venv' -o -path './venv' -o -path './node_modules' -o -path './build' -o -path './DerivedData' -o -path './.dart_tool' \) -prune \
    -o -type f \
    \( -name 'PROJECT_COMMAND_CENTER.md' -o -name 'AGENTS.md' -o -name 'APP_PROJECT_KB.md' -o -name 'SKILL.md' -o -name 'pubspec.yaml' -o -name 'pyproject.toml' -o -name 'Package.swift' -o -name 'package.json' \) \
    -print | sed 's#^./##' | sort
}

write_json_array_from_stdin() {
  local first=1
  printf '['
  while IFS= read -r item; do
    [[ -n "$item" ]] || continue
    if [[ "$first" -eq 0 ]]; then printf ','; fi
    printf '"%s"' "$(json_escape "$item")"
    first=0
  done
  printf ']'
}

require_git_repo
root="$(repo_root)"
cd "$root"

ts="$(date +%Y%m%d_%H%M%S)"
mkdir -p .agent/handoffs .agent/telemetry

branch="$(git branch --show-current 2>/dev/null || true)"
head_full="$(git rev-parse HEAD 2>/dev/null || echo none)"
head_short="$(git rev-parse --short HEAD 2>/dev/null || echo none)"
remote_origin="$(git remote get-url origin 2>/dev/null | redact_remote || true)"
project_type="$(detect_project_type)"
entrypoints="$(find_entrypoints || true)"
validation_commands="$(suggest_validation_commands "$project_type")"

{
  echo "# Agent Workspace Snapshot"
  echo
  echo "Generated at: $ts"
  echo "Repo root: $root"
  echo "Branch: ${branch:-unknown}"
  echo "HEAD: $head_full"
  echo "Remote origin: ${remote_origin:-none}"
  echo "Detected project type: $project_type"
  echo
  echo "## Git status"
  echo '```text'
  git status --short 2>/dev/null || true
  echo '```'
  echo
  echo "## Diff stat"
  echo '```text'
  git diff --stat 2>/dev/null || true
  echo '```'
  echo
  echo "## Recent commits"
  echo '```text'
  git log -5 --oneline 2>/dev/null || true
  echo '```'
  echo
  echo "## Detected entrypoints"
  if [[ -n "$entrypoints" ]]; then
    printf '%s\n' "$entrypoints" | sed 's/^/- /'
  else
    echo "- none"
  fi
  echo
  echo "## Suggested validation commands"
  printf '%s\n' "$validation_commands" | sed 's/^/- `/' | sed 's/$/`/'
  echo
  echo "## Operating note"
  echo "Use this snapshot as an index. Prefer ls/grep/read on scoped files before loading large documents or logs."
} > .agent/current_state.md

{
  printf '{\n'
  printf '  "schema_version": "1",\n'
  printf '  "generated_at": "%s",\n' "$(json_escape "$ts")"
  printf '  "repo": {\n'
  printf '    "root": "%s",\n' "$(json_escape "$root")"
  printf '    "branch": "%s",\n' "$(json_escape "${branch:-unknown}")"
  printf '    "head": "%s",\n' "$(json_escape "$head_full")"
  printf '    "project_type": "%s"\n' "$(json_escape "$project_type")"
  printf '  },\n'
  printf '  "entrypoints": '
  printf '%s\n' "$entrypoints" | write_json_array_from_stdin
  printf ',\n'
  printf '  "validation_commands": '
  printf '%s\n' "$validation_commands" | write_json_array_from_stdin
  printf '\n}\n'
} > .agent/catalog.json

{
  echo "# NEXT_AGENT_PROMPT"
  echo
  echo "Goal: continue from current repo state using Verify First, Trust Telemetry, and Assume Isolation."
  echo
  echo "## Version sync gate"
  echo "1. git fetch origin"
  echo "2. Confirm current branch, clean worktree, local HEAD, target remote HEAD, and base HEAD."
  echo '3. If local is behind the target branch head: STOP and report. Only run `git pull --ff-only` when the task packet explicitly authorizes it.'
  echo "4. If fast-forward fails, branch mismatches, or worktree is dirty: STOP and report. Do not modify files."
  echo
  echo "## Read first"
  echo "- .agent/current_state.md"
  echo "- .agent/catalog.json"
  if [[ -n "$entrypoints" ]]; then
    printf '%s\n' "$entrypoints" | sed 's/^/- /'
  fi
  echo
  echo "## Required final output"
  echo "Repo, branch, HEAD before/after, files changed, commands run, validation results, remaining risks, open loops."
} > .agent/handoffs/NEXT_AGENT_PROMPT.md

{
  printf '{\n'
  printf '  "schema_version": "1",\n'
  printf '  "generated_at": "%s",\n' "$(json_escape "$ts")"
  printf '  "repo_root": "%s",\n' "$(json_escape "$root")"
  printf '  "branch": "%s",\n' "$(json_escape "${branch:-unknown}")"
  printf '  "head": "%s",\n' "$(json_escape "$head_full")"
  printf '  "project_type": "%s",\n' "$(json_escape "$project_type")"
  printf '  "status": "snapshot_created"\n'
  printf '}\n'
} > ".agent/telemetry/snapshot_${ts}.json"

log "wrote .agent/current_state.md"
log "wrote .agent/catalog.json"
log "wrote .agent/handoffs/NEXT_AGENT_PROMPT.md"
log "wrote .agent/telemetry/snapshot_${ts}.json"
warn "generated files may contain local paths; keep runtime outputs gitignored unless deliberately curated."
