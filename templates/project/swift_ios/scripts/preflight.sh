#!/usr/bin/env bash
# Purpose: Run Swift iOS preflight checks without changing signing settings.
# Usage: bash scripts/preflight.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/preflight.sh

Run Swift iOS preflight checks without changing signing settings.
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
echo "Branch: $(git branch --show-current 2>/dev/null || true)"
echo "HEAD: $(git rev-parse --short HEAD 2>/dev/null || echo none)"
git diff --stat 2>/dev/null || true
has xcodebuild && xcodebuild -list || warn "xcodebuild missing or no Xcode project"
if [[ -f Package.swift ]] && has swift; then swift test; fi
has xcrun && xcrun simctl list devices available | head -80 || warn "xcrun missing"
