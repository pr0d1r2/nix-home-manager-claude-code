#!/usr/bin/env bats

SRC="lib/merge-mcp.sh"

@test "creates parent directory before writing target" {
  # shellcheck disable=SC2016
  grep -q 'mkdir -p "$(dirname "$target")"' "$SRC"
}

@test "creates parent directory before writing managed keys" {
  # shellcheck disable=SC2016
  grep -q 'mkdir -p "$(dirname "$managed_keys_file")"' "$SRC"
}
