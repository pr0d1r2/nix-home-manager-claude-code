#!/usr/bin/env bash
FLAG="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.caveman-active"

[ -L "$FLAG" ] && exit 0
[ ! -f "$FLAG" ] && exit 0

MODE=$(head -c 64 "$FLAG" 2>/dev/null | tr -d '\n\r' | tr '[:upper:]' '[:lower:]')
MODE=$(printf '%s' "$MODE" | tr -cd 'a-z0-9-')

case "$MODE" in
off | lite | full | ultra | wenyan-lite | wenyan | wenyan-full | wenyan-ultra | commit | review | compress) ;;
*) exit 0 ;;
esac

if [ -z "$MODE" ] || [ "$MODE" = "full" ]; then
  printf '\033[38;5;172m[CAVEMAN]\033[0m'
else
  SUFFIX=$(printf '%s' "$MODE" | tr '[:lower:]' '[:upper:]')
  printf '\033[38;5;172m[CAVEMAN:%s]\033[0m' "$SUFFIX"
fi
