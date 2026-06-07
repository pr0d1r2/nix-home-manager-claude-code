#!/bin/bash
# PostToolUse hook: after a git commit touching justfiles,
# instruct Claude to extract embedded scripts.
# Only applies to repos that have justfiles.
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# Only act on git commit commands
echo "$COMMAND" | grep -qE 'git commit' || exit 0

# Only act in repos that have justfiles
[ -f justfile ] || [ -f Justfile ] || ls justfile.d/*.just >/dev/null 2>&1 || exit 0

# Check if the commit touched any justfile
CHANGED=$(git diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | grep -iE 'justfile|\.just$' || true)
[ -z "$CHANGED" ] && exit 0

# Detect project type for test framework
if [ -f Gemfile ]; then
  SKILL="/extract-justfile-scripts-ruby"
  TESTS="RSpec"
else
  SKILL="/extract-justfile-scripts"
  TESTS="bats"
fi

cat <<EOF
JUSTFILE_CHANGED: The commit you just made modified justfile(s). Per project convention, embedded shell in justfile recipes must be extracted to separate script files with ${TESTS} test coverage. Please now:

1. Run ${SKILL} to extract any multi-line embedded shell from the changed justfiles
2. If any scripts were extracted, create a follow-up commit with the message: "Extract embedded shell from justfile recipes"

Do NOT amend the previous commit -- always create a new follow-up commit.
EOF
