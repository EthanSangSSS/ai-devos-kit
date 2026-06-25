#!/usr/bin/env bash
# Purpose: Check Xcode, Swift, and simulator dependencies.
# Usage: bash scripts/doctor.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/doctor.sh

Check Xcode, Swift, and simulator dependencies.
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



for c in xcodebuild xcode-select xcrun swift; do has "$c" && echo "OK $c: $($c --version 2>&1 | head -1)" || echo "recommended: install $c"; done
has xcrun && xcrun simctl list devices available | head -80 || true
