#!/usr/bin/env bash
# Purpose: Validate agent workspace scripts in an isolated temporary git repo.
# Usage: bash tests/validate_agent_workspace.sh
set -euo pipefail

fail() { printf 'P1: %s\n' "$*" >&2; exit 1; }
log() { printf '[validate-agent-workspace] %s\n' "$*"; }

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  fail "must be run from inside the ai-devos-kit repository"
fi

kit_root="$(git rev-parse --show-toplevel)"
cd "$kit_root"

for script in scripts/agent_workspace_snapshot.sh scripts/agent_run_init.sh; do
  [[ -f "$script" ]] || fail "missing $script"
  grep -q 'set -euo pipefail' "$script" || fail "$script must use set -euo pipefail"
  grep -q 'git rev-parse --show-toplevel' "$script" || fail "$script must anchor to the git repo root"
  if grep -Eq 'find +("?\$HOME"?|/Users|/) ' "$script"; then
    fail "$script appears to contain a broad filesystem scan"
  fi
  log "static check passed: $script"
done

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

cd "$tmp_dir"
git init -q
git config user.email "agent-workspace-test@example.invalid"
git config user.name "Agent Workspace Test"
cat > README.md <<'EOF'
# Fixture Repo
EOF
cat > pubspec.yaml <<'EOF'
name: fixture_repo
description: Fixture repo for agent workspace validation.
EOF
mkdir -p docs
: > docs/.gitkeep
cat > AGENTS.md <<'EOF'
# Agent Rules
EOF
git add README.md pubspec.yaml AGENTS.md docs/.gitkeep
git commit -m "test: init fixture repo" >/dev/null

bash "$kit_root/scripts/agent_workspace_snapshot.sh"

[[ -f .agent/current_state.md ]] || fail "missing .agent/current_state.md"
[[ -f .agent/catalog.json ]] || fail "missing .agent/catalog.json"
[[ -f .agent/handoffs/NEXT_AGENT_PROMPT.md ]] || fail "missing .agent/handoffs/NEXT_AGENT_PROMPT.md"
find .agent/telemetry -name 'snapshot_*.json' -type f | grep -q . || fail "missing snapshot telemetry json"

grep -q 'flutter_or_dart' .agent/catalog.json || fail "catalog should detect flutter_or_dart fixture"
grep -q 'AGENTS.md' .agent/catalog.json || fail "catalog should include AGENTS.md entrypoint"
grep -q 'Version sync gate' .agent/handoffs/NEXT_AGENT_PROMPT.md || fail "handoff prompt should include version sync gate"
grep -Fq 'Only run `git pull --ff-only` when the task packet explicitly authorizes it.' .agent/handoffs/NEXT_AGENT_PROMPT.md || fail "handoff prompt should require explicit pull authorization"
if grep -Fq 'If local HEAD differs from the target branch head, run: git pull --ff-only origin <branch>' .agent/handoffs/NEXT_AGENT_PROMPT.md; then
  fail "handoff prompt must not prescribe an automatic pull"
fi

bash "$kit_root/scripts/agent_run_init.sh" "Sample Task"
run_dir="$(find .agent/runs -maxdepth 1 -mindepth 1 -type d | head -n 1)"
[[ -n "$run_dir" ]] || fail "missing run directory"
for f in task.md preflight.md git_state_before.txt commands.log validation.md open_loops.md final_output.md telemetry.json; do
  [[ -f "$run_dir/$f" ]] || fail "missing run artifact: $f"
done

grep -q 'human_review_required' "$run_dir/telemetry.json" || fail "telemetry should require human review by default"
grep -Fq 'Only run `git pull --ff-only` when the task packet explicitly authorizes it.' "$run_dir/preflight.md" || fail "run preflight should require explicit pull authorization"
if grep -Fq 'If local HEAD differs from target head, run git pull --ff-only origin <branch>.' "$run_dir/preflight.md"; then
  fail "run preflight must not prescribe an automatic pull"
fi

log "isolated fixture validation passed"
