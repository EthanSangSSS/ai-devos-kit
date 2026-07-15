#!/usr/bin/env python3
"""Public-safety scan for AI DevOS Kit review-facing files.

This dependency-free check blocks obvious credential and private-key markers in
public docs, prompts, examples, templates, and scripts. It also warns on local
user paths so maintainers can decide whether a path is an intentional placeholder
or a leakage risk.

It is not a complete secret scanner and does not replace gitleaks or human review.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCAN_ROOTS = [
    "README.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "docs",
    "examples",
    "prompts",
    "templates",
    "scripts",
    ".github/PULL_REQUEST_TEMPLATE.md",
]
SCAN_SUFFIXES = {".md", ".txt", ".json", ".yaml", ".yml", ".sh", ".py"}
EXCLUDED_DIRS = {".git", ".venv", "node_modules", "dist", "build", "__pycache__", ".agent"}

BLOCK_PATTERNS: list[tuple[str, re.Pattern[str]]] = [
    ("private key block", re.compile(r"-----BEGIN [A-Z ]*PRIVATE KEY-----")),
    ("GitHub token", re.compile(r"gh[pousr]_[A-Za-z0-9_]{20,}")),
    ("OpenAI project key", re.compile(r"sk-proj-[A-Za-z0-9_-]{20,}")),
    ("AWS access key", re.compile(r"AKIA[0-9A-Z]{16}")),
]

WARN_PATTERNS: list[tuple[str, re.Pattern[str]]] = [
    ("macOS user path", re.compile(r"/Users/[A-Za-z0-9._-]+")),
    ("Linux home path", re.compile(r"/home/[A-Za-z0-9._-]+")),
    ("Windows user path", re.compile(r"[A-Za-z]:\\\\Users\\\\[A-Za-z0-9._-]+")),
    ("unsupported adoption claim", re.compile(r"\b(thousands|millions)\s+of\s+users\b", re.I)),
    ("endorsement claim", re.compile(r"\bofficial\s+openai\s+(project|repo|repository|tool)\b", re.I)),
]


def rel(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def should_scan(path: Path) -> bool:
    parts = path.relative_to(ROOT).parts
    if any(part in EXCLUDED_DIRS for part in parts):
        return False
    return path.is_file() and path.suffix in SCAN_SUFFIXES


def iter_scan_files() -> list[Path]:
    files: list[Path] = []
    for entry in SCAN_ROOTS:
        target = ROOT / entry
        if target.is_file():
            files.append(target)
        elif target.is_dir():
            files.extend(path for path in target.rglob("*") if should_scan(path))
    return sorted(set(files))


def main() -> int:
    blockers: list[str] = []
    warnings: list[str] = []

    for path in iter_scan_files():
        relative = rel(path)
        text = path.read_text(encoding="utf-8", errors="replace")

        for label, pattern in BLOCK_PATTERNS:
            if pattern.search(text):
                blockers.append(f"{relative}: matched {label}")

        for label, pattern in WARN_PATTERNS:
            if pattern.search(text):
                warnings.append(f"{relative}: matched {label}")

    for warning in warnings:
        print(f"WARN: {warning}")

    if blockers:
        print("FAIL: public-safety scan found blockers", file=sys.stderr)
        for blocker in blockers:
            print(f"- {blocker}", file=sys.stderr)
        return 1

    print(f"PASS: public-safety scan checked {len(iter_scan_files())} files with {len(warnings)} warnings")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
