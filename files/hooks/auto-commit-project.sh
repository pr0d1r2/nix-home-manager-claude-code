#!/usr/bin/env bash
set -euo pipefail

# Auto-commit working directory changes after each prompt.
# Uses a lock file to prevent infinite commit loops.

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

LOCK="/tmp/auto-commit-project-$(git rev-parse --show-toplevel | md5sum | cut -d' ' -f1).lock"

# Prevent re-entry
if [ -f "$LOCK" ]; then
  exit 0
fi
trap 'rm -f "$LOCK"' EXIT
touch "$LOCK"

# Check if there are any changes to commit
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  exit 0
fi

git add -A
git commit -m "Auto-commit after prompt at $(date '+%Y-%m-%d %H:%M:%S')" --no-gpg-sign >/dev/null 2>&1

exit 0
