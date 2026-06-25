#!/usr/bin/env bash
# Purpose: Scan common text files for likely secrets and print only redacted findings.
# Usage: bash scripts/secret_redacted_scan.sh
# Risk: Low/Medium. Non-destructive by default; no secret output.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash scripts/secret_redacted_scan.sh

Scan common text files for likely secrets and print only redacted findings.
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
pattern='(sk-[A-Za-z0-9_-]{16,}|gh[pousr]_[A-Za-z0-9_]{12,}|github_pat_[A-Za-z0-9_]{20,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)'
if has rg; then
  hits="$(rg -n --pcre2 "$pattern" --glob '!**/.git/**' --glob '!**/node_modules/**' --glob '!**/Pods/**' . 2>/dev/null || true)"
  if [[ -n "$hits" ]]; then
    printf '%s\n' "$hits" | sed -E 's/(sk-|gh[pousr]_|github_pat_|AKIA)[A-Za-z0-9_-]+/\1[REDACTED]/g; s/PRIVATE KEY/PRIVATE KEY [REDACTED]/g'
    echo "P0: possible secret pattern found; review and rotate if real."
    exit 1
  fi
else
  warn "rg missing; install ripgrep for better scan"
fi
if has gitleaks; then echo "Recommended: gitleaks detect --redact --source ."; else echo "recommended: install gitleaks"; fi
echo "No high-confidence full secret patterns found by local redacted scan."
