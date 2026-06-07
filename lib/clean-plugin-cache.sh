#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="$1"

if [ ! -d "$CACHE_DIR" ]; then
  exit 0
fi

for dir in "$CACHE_DIR"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  found=false
  for managed in $MANAGED_NAMES; do
    if [ "$name" = "$managed" ]; then
      found=true
      break
    fi
  done
  if [ "$found" = "false" ]; then
    rm -rf "$dir"
  fi
done
