#!/usr/bin/env bash
set -euo pipefail

GEN="$1"
HOME_FILES="$GEN/home-files"
FAIL=0

check_file() {
  if [ ! -e "$HOME_FILES/$1" ]; then
    echo "FAIL: missing $1"
    FAIL=1
  fi
}

check_dir() {
  if [ ! -d "$HOME_FILES/$1" ]; then
    echo "FAIL: missing directory $1"
    FAIL=1
  fi
}

check_activation() {
  if ! grep -q "$1" "$GEN/activate"; then
    echo "FAIL: activation missing $1"
    FAIL=1
  fi
}

check_wrapper() {
  local wrapper
  wrapper="$(grep -o '/nix/store/[^ ]*run-merge-settings.sh' "$GEN/activate")"
  if ! grep -q "$1" "$wrapper"; then
    echo "FAIL: merge-settings wrapper missing $1"
    FAIL=1
  fi
}

check_dir ".claude/hooks"
check_dir ".claude/commands"

# Hook scripts from presets.all
check_file ".claude/hooks/caveman-activate.sh"
check_file ".claude/hooks/caveman-mode-tracker.sh"
check_file ".claude/hooks/caveman-statusline.sh"
check_file ".claude/hooks/cavemem-statusline.sh"
check_file ".claude/hooks/cavekit-statusline.sh"
check_file ".claude/hooks/auto-commit.sh"
check_file ".claude/hooks/auto-commit-project.sh"
check_file ".claude/hooks/coverage-check.sh"
check_file ".claude/hooks/justfile-extract.sh"
check_file ".claude/hooks/session-id.sh"
check_file ".claude/hooks/statusline.sh"
check_file ".claude/hooks/gh-statusline.sh"
check_file ".claude/hooks/git-status-statusline.sh"
check_file ".claude/hooks/rtk-rewrite.sh"
check_file ".claude/hooks/rtk-statusline.sh"
check_file ".claude/hooks/semble-statusline.sh"
check_file ".claude/hooks/astfold-statusline.sh"

# Hook count
count="$(find "$HOME_FILES/.claude/hooks" -type l -o -type f | wc -l | tr -d ' ')"
if [ "$count" -ne 17 ]; then
  echo "FAIL: expected 17 hook scripts, got $count"
  FAIL=1
fi

# Commands
check_file ".claude/commands/cover-rb.md"
check_file ".claude/commands/cover-sh.md"
check_file ".claude/commands/extract-justfile-scripts.md"
check_file ".claude/commands/extract-justfile-scripts-ruby.md"
check_file ".claude/commands/humor/sarcasm.md"
check_file ".claude/commands/humor/terminator.md"

# Activation script
check_activation "merge-settings.sh"
check_wrapper "permissions.deny"
check_wrapper "spinnerVerbs"
check_wrapper "caveman-activate.sh"
check_wrapper "SessionStart"
check_wrapper "UserPromptSubmit"

if [ "$FAIL" -ne 0 ]; then
  exit 1
fi

echo "All presets.all checks passed"
