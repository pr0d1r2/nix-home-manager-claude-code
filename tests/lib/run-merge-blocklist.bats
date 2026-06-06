#!/usr/bin/env bats

SRC="lib/run-merge-blocklist.sh"

@test "NIX_BLOCKED uses heredoc to safely embed JSON" {
  grep -q "cat <<'__NIX_JSON_EOF__'" "$SRC"
  grep -q '@nixBlocked@' "$SRC"
}

@test "managed-blocked-keys file uses heredoc" {
  grep -q "__NIX_JSON_EOF__" "$SRC"
}

@test "no bare single or double quoted JSON var" {
  run ! grep -qE "NIX_BLOCKED=['\"]@" "$SRC"
}
