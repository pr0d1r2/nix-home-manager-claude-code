#!/bin/bash
# PostToolUse hook: after a git commit, run modular coverage checkers.
# Each checker under coverage.d/ receives changed files and outputs
# instructions if it finds issues. Outputs are concatenated.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only act on git commit commands
echo "$COMMAND" | grep -qE 'git commit' || exit 0

# Get files added/modified in the commit
CHANGED=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null || true)
[ -z "$CHANGED" ] && exit 0

# Don't trigger on commits that are themselves coverage/docs additions
COMMIT_MSG=$(git log -1 --format=%s 2>/dev/null || true)
echo "$COMMIT_MSG" | grep -qiE 'cover|spec|test|bats|readme|documentation' && exit 0

# Run all modular checkers
HOOK_DIR="$(cd "$(dirname "$0")" && pwd)/coverage.d"
[ -d "$HOOK_DIR" ] || exit 0

OUTPUT=""
for checker in "$HOOK_DIR"/*.sh; do
    [ -f "$checker" ] || continue
    RESULT=$(bash "$checker" "$CHANGED" 2>/dev/null || true)
    if [ -n "$RESULT" ]; then
        OUTPUT="${OUTPUT}${RESULT}\n\n"
    fi
done

[ -z "$OUTPUT" ] && exit 0

echo -e "$OUTPUT"
