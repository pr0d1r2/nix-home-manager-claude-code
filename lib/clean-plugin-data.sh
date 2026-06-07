#!/usr/bin/env bash
set -euo pipefail

DATA_DIR="$1"

if [ ! -d "$DATA_DIR" ]; then
  exit 0
fi

for dir in "$DATA_DIR"/*/; do
  [ -d "$dir" ] || continue
  name="$(basename "$dir")"
  found=false
  for managed in $MANAGED_PLUGINS; do
    if [ "$name" = "$managed" ]; then
      found=true
      break
    fi
  done
  if [ "$found" = "false" ]; then
    rm -rf "$dir"
  fi
done
