#!/usr/bin/env bash
# Purpose: Inspect GitHub CLI auth and print safe GitHub repo bootstrap commands; push only with --push.
# Usage: bash scripts/github_private_repo_bootstrap.sh [--push]
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/github_private_repo_bootstrap.sh [--push]

Inspect GitHub CLI auth and print safe GitHub repo bootstrap commands; push only with --push.
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



push="false"; [[ "${1:-}" == "--push" ]] && push="true"
root="$(repo_root)"; cd "$root"
if ! has gh; then warn "gh missing. Install GitHub CLI."; exit 0; fi
gh auth status || warn "gh auth not ready"
if [[ -z "$(git remote 2>/dev/null || true)" ]]; then
  name="$(basename "$root")"
  echo "Suggested: gh repo create $name --public --source=$root --remote=origin"
  echo "Then open a PR and use prompts/chatgpt/github_connector_pr_review.md"
else
  git remote -v
fi
if [[ "$push" == "true" ]]; then
  git push -u origin HEAD
else
  echo "Not pushing. Pass --push only after you explicitly decide to publish."
fi
