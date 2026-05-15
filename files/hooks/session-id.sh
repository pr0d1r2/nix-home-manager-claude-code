#!/bin/bash
# SessionStart hook: inject session ID into context
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')
[ -z "$SESSION_ID" ] && exit 0

jq -n --arg sid "$SESSION_ID" '{
  "additionalContext": ("Current session ID: " + $sid)
}'
