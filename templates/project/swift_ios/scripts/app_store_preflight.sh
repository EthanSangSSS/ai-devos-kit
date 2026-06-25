#!/usr/bin/env bash
# Purpose: Run static App Store readiness checks without touching signing or App Store credentials.
# Usage: bash scripts/app_store_preflight.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/app_store_preflight.sh

Run static App Store readiness checks without touching signing or App Store credentials.
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
find . -name Info.plist -o -name PrivacyInfo.xcprivacy -o -name '*.storekit' | sort
for item in "Privacy policy URL" "IAP product ids" "Restore purchase" "Screenshots" "Age rating" "Review notes"; do echo "Check manually: $item"; done
echo "Do not change bundle id/team id/IAP product ids in this script."
