#!/usr/bin/env bash
set -euo pipefail

GEN="$1"

for f in \
    ".claude/hooks/test-hook.sh" \
    ".claude/commands/test-cmd.md" \
    ".claude/rules/test-rule.md" \
    ".claude/keybindings.json" \
    ".claude/CLAUDE.md" \
    ".claude/.credentials.json"; do
    if [ ! -e "$GEN/home-files/$f" ]; then
        echo "FAIL: missing $f"
        exit 1
    fi
done

echo "All integration checks passed"
