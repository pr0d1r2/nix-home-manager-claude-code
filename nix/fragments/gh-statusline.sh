#!/usr/bin/env bash
if ! command -v gh >/dev/null 2>&1; then
  exit 0
fi
if gh auth token >/dev/null 2>&1; then
  printf '\033[38;5;147m[GH]\033[0m'
else
  printf '\033[38;5;196m[GH]\033[0m'
fi
