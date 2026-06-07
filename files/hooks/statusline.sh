#!/usr/bin/env bash
left=""
right=""
for hook in ~/.claude/hooks/*-statusline.sh; do
  [ -f "$hook" ] || continue
  result="$(bash "$hook" 2>/dev/null)"
  [ -n "$result" ] || continue
  case "$hook" in
  *git-status-statusline.sh)
    right="$result"
    ;;
  *)
    left="${left:+$left }$result"
    ;;
  esac
done

if [ -n "$left" ] && [ -n "$right" ]; then
  printf '%s  %s' "$left" "$right"
elif [ -n "$right" ]; then
  printf '%s' "$right"
else
  printf '%s' "$left"
fi
