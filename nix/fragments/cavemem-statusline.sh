#!/usr/bin/env bash
if ! @cavemem@ --help >/dev/null 2>&1; then
  exit 0
fi
pid="$(cat ~/.cavemem/worker.pid 2>/dev/null)"
if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
  printf '\033[38;5;172m[CAVEMEM]\033[0m'
else
  printf '\033[38;5;196m[CAVEMEM]\033[0m'
fi
