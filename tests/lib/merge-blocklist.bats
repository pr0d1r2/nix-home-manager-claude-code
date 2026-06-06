#!/usr/bin/env bats

SRC="lib/merge-blocklist.sh"

@test "creates parent directory before writing target" {
  # shellcheck disable=SC2016
  grep -q 'mkdir -p "$(dirname "$target")"' "$SRC"
}
