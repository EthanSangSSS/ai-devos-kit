#!/usr/bin/env bash
# Purpose: Create a Swift iOS project workspace scaffold and install AI DevOS template files.
# Usage: bash scripts/create_swift_ios_project.sh <project_name> <app_display_name> <bundle_id>
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/create_swift_ios_project.sh <project_name> <app_display_name> <bundle_id>

Create a Swift iOS project workspace scaffold and install AI DevOS template files.
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



if [[ $# -ne 3 ]]; then usage; exit 2; fi
project_name="$1"; app_display_name="$2"; bundle_id="$3"
kit_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -e "$project_name" ]]; then warn "target exists: $project_name"; exit 1; fi
mkdir -p "$project_name"/{docs,scripts,.github,App,Tests}
cd "$project_name"
cp "$kit_root/templates/project/swift_ios/AGENTS.md" ./AGENTS.md
cp "$kit_root/templates/project/swift_ios/README.template.md" ./README.md
cp -R "$kit_root/templates/project/swift_ios/docs/." docs/
cp -R "$kit_root/templates/project/swift_ios/scripts/." scripts/
cp -R "$kit_root/templates/project/swift_ios/github/." .github/
chmod +x scripts/*.sh || true
cat > App/README.md <<EOF
# $app_display_name

Bundle id target: $bundle_id

Create the Xcode project manually or with your preferred generator, then keep AGENTS.md and docs as source of truth.
EOF
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then git init; fi
git add .
if ! git diff --cached --quiet; then git commit -m "Initialize Swift iOS project with AI DevOS Kit"; fi
log "Xcode project generation is intentionally manual unless you add XcodeGen/Tuist explicitly."
