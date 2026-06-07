#!/usr/bin/env bash
set -euo pipefail

target="${1:?usage: merge-mcp.sh TARGET MANAGED_KEYS}"
managed_keys_file="${2:?usage: merge-mcp.sh TARGET MANAGED_KEYS}"
nix_mcp="${NIX_MCP:?NIX_MCP env var required}"

if [ ! -f "$target" ]; then
  existing='{"mcpServers":{}}'
else
  existing="$(cat "$target")"
fi

old_managed='[]'
if [ -f "$managed_keys_file" ]; then
  old_managed="$(cat "$managed_keys_file")"
fi

new_managed="$(echo "$nix_mcp" | jq -c '[.mcpServers | keys[]] | sort')"

result="$(
  jq -n \
    --argjson existing "$existing" \
    --argjson nix "$nix_mcp" \
    --argjson old_managed "$old_managed" \
    '
    ($old_managed - ($nix.mcpServers | keys)) as $stale |
    ($existing | .mcpServers |= (delpaths([$stale[] | [.]]))) as $cleaned |
    $cleaned * $nix
  '
)"

mkdir -p "$(dirname "$target")"
tmp="${target}.tmp"
echo "$result" >"$tmp"
mv "$tmp" "$target"

mkdir -p "$(dirname "$managed_keys_file")"
echo "$new_managed" >"$managed_keys_file"
