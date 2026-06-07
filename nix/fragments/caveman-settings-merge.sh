#!/usr/bin/env bash
# shellcheck shell=bash
set -euo pipefail

SETTINGS="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"

if [ ! -f "$SETTINGS" ]; then
  exit 0
fi

if grep -q 'caveman-activate' "$SETTINGS" 2>/dev/null; then
  exit 0
fi

@jq@ '
  .hooks.SessionStart = (.hooks.SessionStart // []) + [
    {"hooks": [{"type": "command", "command": "bash ~/.claude/hooks/caveman-activate.sh", "timeout": 5}]}
  ] |
  .hooks.UserPromptSubmit = (.hooks.UserPromptSubmit // []) + [
    {"hooks": [{"type": "command", "command": "bash ~/.claude/hooks/caveman-mode-tracker.sh", "timeout": 5}]}
  ] |
  if .statusLine then . else .statusLine = {"type": "command", "command": "bash ~/.claude/hooks/statusline.sh"} end
' "$SETTINGS" >"$SETTINGS.tmp" && mv "$SETTINGS.tmp" "$SETTINGS"
