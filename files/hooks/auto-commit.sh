#!/usr/bin/env bash
set -euo pipefail

cd ~/.claude

# Check if there are any changes to commit
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    exit 0
fi

# Stage all tracked changes and new untracked files (respecting .gitignore)
git add -A

# Commit with a timestamp-based message
git commit -m "Auto-commit after prompt at $(date '+%Y-%m-%d %H:%M:%S')" --no-gpg-sign >/dev/null 2>&1

exit 0
