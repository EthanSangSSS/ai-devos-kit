#!/usr/bin/env bash
# Purpose: Prepare iOS simulator QA for Swift app without claiming visual acceptance.
# Usage: bash scripts/xcode_simulator_qa_prep.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/xcode_simulator_qa_prep.sh

Prepare iOS simulator QA for Swift app without claiming visual acceptance.
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



has xcrun && xcrun simctl list devices available | head -100 || warn "xcrun missing"
has xcodebuild && echo "Suggested: xcodebuild build -scheme <SCHEME> -destination 'platform=iOS Simulator,name=<DEVICE>'" || warn "xcodebuild missing"
echo "Computer Use visual QA requires explicit user request."
