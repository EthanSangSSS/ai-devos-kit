#!/usr/bin/env bash
# Purpose: Install AI DevOS templates into the current existing project without overwriting user files.
# Usage: bash $AI_DEVOS_KIT_ROOT/scripts/install_project_kit.sh [flutter_ios|swift_ios|ai_agent_project]
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash $AI_DEVOS_KIT_ROOT/scripts/install_project_kit.sh [flutter_ios|swift_ios|ai_agent_project]

Install AI DevOS templates into the current existing project without overwriting user files.
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
copy_tree_missing() {
  local src_dir="$1" dst_dir="$2"
  mkdir -p "$dst_dir"
  find "$src_dir" -type f | while IFS= read -r src_file; do
    local rel="${src_file#$src_dir/}"
    copy_missing "$src_file" "$dst_dir/$rel"
  done
}



kit_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
project_root="$(repo_root)"; cd "$project_root"
type="${1:-}"
if [[ -z "$type" ]]; then
  if [[ -f pubspec.yaml && -d ios ]]; then type="flutter_ios";
  elif compgen -G "*.xcodeproj" >/dev/null || compgen -G "*.xcworkspace" >/dev/null || [[ -f Package.swift ]]; then type="swift_ios";
  else type="ai_agent_project"; fi
fi
src="$kit_root/templates/project/$type"
if [[ ! -d "$src" ]]; then warn "unknown template: $type"; exit 2; fi
if [[ -f AGENTS.md ]]; then cp "$src/AGENTS.md" AGENTS.md.recommended; else cp "$src/AGENTS.md" AGENTS.md; fi
[[ -f README.md ]] || cp "$src/README.template.md" README.md
mkdir -p docs scripts .github
for f in "$src"/docs/*; do copy_missing "$f" "docs/$(basename "$f")"; done
for f in "$src"/scripts/*; do copy_missing "$f" "scripts/$(basename "$f")"; done
copy_tree_missing "$src/github" ".github"
chmod +x scripts/*.sh 2>/dev/null || true
log "installed template type: $type"
log "run: bash scripts/preflight.sh && bash scripts/secret_redacted_scan.sh"
