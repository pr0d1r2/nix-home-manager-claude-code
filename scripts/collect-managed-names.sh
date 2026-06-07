#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$1"

for subdir in hooks commands; do
  dir="$REPO_DIR/files/$subdir"
  if [[ -d "$dir" ]]; then
    (cd "$dir" && find . -type f | sed 's|^\./||' | while read -r f; do
      echo "${subdir}/${f}"
    done)
  fi
done
