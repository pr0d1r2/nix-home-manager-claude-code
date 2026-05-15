#!/usr/bin/env bash
set -euo pipefail

export PATH="@jq@:@coreutils@:$PATH"

NIX_MCP="@nixMcp@" \
    bash @mergeScript@ \
    "$HOME/.claude/.mcp.json" \
    "$HOME/.claude/.nix-managed-mcp-keys.json"
