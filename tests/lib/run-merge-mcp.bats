#!/usr/bin/env bats

SRC="lib/run-merge-mcp.sh"

@test "NIX_MCP uses single quotes to prevent JSON double-quote breakage" {
  grep -q "NIX_MCP='@nixMcp@'" "$SRC"
}
