#!/usr/bin/env bash
# Purpose: Initialize a standard per-task agent run artifact directory.
# Usage: bash scripts/agent_run_init.sh [task-slug]
# Risk: Low. Non-destructive; writes only under .agent/runs/ in the current git repo.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/agent_run_init.sh [task-slug]

Create .agent/runs/YYYYMMDD_HHMMSS_<slug>/ with standard task, preflight,
validation, open-loop, telemetry, and final-output files.
EOF
}

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
  usage
  exit 0
fi

log() { printf '[agent-run] %s\n' "$*"; }
warn() { printf '[agent-run:warn] %s\n' "$*" >&2; }

repo_root() {
  git rev-parse --show-toplevel 2>/dev/null
}

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

sanitize_slug() {
  local raw="${1:-agent-task}"
  printf '%s' "$raw" \
    | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9._-' '-' \
    | sed -E 's/^-+//; s/-+$//; s/-+/-/g'
}

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "P1: not inside a git repository" >&2
  exit 1
fi

root="$(repo_root)"
cd "$root"

ts="$(date +%Y%m%d_%H%M%S)"
slug="$(sanitize_slug "${1:-agent-task}")"
[[ -n "$slug" ]] || slug="agent-task"
run_dir=".agent/runs/${ts}_${slug}"
mkdir -p "$run_dir"

branch="$(git branch --show-current 2>/dev/null || true)"
head_full="$(git rev-parse HEAD 2>/dev/null || echo none)"
head_short="$(git rev-parse --short HEAD 2>/dev/null || echo none)"

{
  echo "# Agent Run Task"
  echo
  echo "Run directory: $run_dir"
  echo "Created at: $ts"
  echo "Task slug: $slug"
  echo
  echo "## Goal"
  echo "TODO: state the task goal before making changes."
  echo
  echo "## Scope"
  echo "TODO: list allowed files/directories and forbidden changes."
} > "$run_dir/task.md"

{
  echo "# Preflight"
  echo
  echo "Repo root: $root"
  echo "Branch: ${branch:-unknown}"
  echo "HEAD: $head_full"
  echo
  echo "## Version sync gate"
  echo "1. git fetch origin"
  echo "2. Confirm branch, clean worktree, local HEAD, remote target HEAD, and base HEAD."
  echo "3. If local HEAD differs from target head, run git pull --ff-only origin <branch>."
  echo "4. If fast-forward fails, branch mismatches, or worktree is dirty: STOP and report."
  echo
  echo "## Initial git status"
  echo '```text'
  git status --short 2>/dev/null || true
  echo '```'
} > "$run_dir/preflight.md"

{
  echo "Branch: ${branch:-unknown}"
  echo "HEAD: $head_full"
  echo
  echo "git status --short:"
  git status --short 2>/dev/null || true
  echo
  echo "git diff --stat:"
  git diff --stat 2>/dev/null || true
} > "$run_dir/git_state_before.txt"

cat > "$run_dir/commands.log" <<'EOF'
# Commands Log
# Append commands and raw pass/fail observations here.
EOF

cat > "$run_dir/validation.md" <<'EOF'
# Validation

## Commands run

- TODO

## Result

- TODO: pass/fail/blocked

## Evidence

- TODO: paste bounded command summaries, not secrets or full noisy logs.
EOF

cat > "$run_dir/open_loops.md" <<'EOF'
# Open Loops

- TODO: list unresolved risks, follow-ups, assumptions, and validation gaps.
EOF

cat > "$run_dir/final_output.md" <<'EOF'
# Final Output

1. Repo, branch, HEAD before/after
2. Files changed
3. Commands run with pass/fail
4. Validation evidence
5. Remaining risks
6. Next recommended action
EOF

{
  printf '{\n'
  printf '  "schema_version": "1",\n'
  printf '  "created_at": "%s",\n' "$(json_escape "$ts")"
  printf '  "repo_root": "%s",\n' "$(json_escape "$root")"
  printf '  "branch": "%s",\n' "$(json_escape "${branch:-unknown}")"
  printf '  "head_before": "%s",\n' "$(json_escape "$head_full")"
  printf '  "head_after": null,\n'
  printf '  "agent": null,\n'
  printf '  "commands_run": 0,\n'
  printf '  "failed_commands": 0,\n'
  printf '  "files_read": 0,\n'
  printf '  "files_modified": 0,\n'
  printf '  "validation_passed": null,\n'
  printf '  "human_review_required": true\n'
  printf '}\n'
} > "$run_dir/telemetry.json"

log "created $run_dir"
warn "runtime run artifacts are intended to be gitignored unless deliberately curated."
