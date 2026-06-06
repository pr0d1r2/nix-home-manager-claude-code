#!/usr/bin/env bats

SRC="lib/run-merge-mcp.sh"

@test "NIX_MCP uses heredoc to safely embed JSON" {
  grep -q "cat <<'__NIX_JSON_EOF__'" "$SRC"
  grep -q '@nixMcp@' "$SRC"
}

@test "no bare single or double quoted JSON var" {
  run ! grep -qE "NIX_MCP=['\"]@" "$SRC"
}
