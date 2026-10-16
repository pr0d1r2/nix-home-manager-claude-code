#!/usr/bin/env bash
# Fail when a GitHub repo is locked more than once in a flake.lock.
# Duplicates mean some input lacks a `follows`, so the closure carries
# several builds of the same tool (e.g. several rtk versions).
# Usage: check-lock-unique.sh <flake.lock> <owner/repo>...
set -euo pipefail

if [ "$#" -lt 2 ]; then
  echo "usage: check-lock-unique.sh <flake.lock> <owner/repo>..." >&2
  exit 2
fi

lock="$1"
shift

if [ ! -f "$lock" ]; then
  echo "check-lock-unique: $lock not found" >&2
  exit 2
fi

status=0
for repo in "$@"; do
  nodes=$(jq -r --arg repo "$repo" '
    .nodes | to_entries[]
    | select(.value.original.owner != null and .value.original.repo != null)
    | select(((.value.original.owner + "/" + .value.original.repo) | ascii_downcase) == ($repo | ascii_downcase))
    | .key' "$lock")
  count=$(printf '%s' "$nodes" | grep -c . || true)
  if [ "$count" -gt 1 ]; then
    echo "$repo locked $count times: $(echo "$nodes" | paste -sd " " -)"
    status=1
  fi
done

exit "$status"
