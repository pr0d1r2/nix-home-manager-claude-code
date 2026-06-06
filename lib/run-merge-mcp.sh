#!/usr/bin/env bash
set -euo pipefail

export PATH="@jq@:@coreutils@:$PATH"

NIX_MCP=$(
    cat <<'__NIX_JSON_EOF__'
@nixMcp@
__NIX_JSON_EOF__
) \
    bash @mergeScript@ \
    "$HOME/.claude/.mcp.json" \
    "$HOME/.claude/.nix-managed-mcp-keys.json"
