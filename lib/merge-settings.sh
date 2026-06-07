#!/usr/bin/env bash
set -euo pipefail

target="${1:?usage: merge-settings.sh TARGET MANAGED_KEYS}"
managed_keys_file="${2:?usage: merge-settings.sh TARGET MANAGED_KEYS}"
nix_settings="${NIX_SETTINGS:?NIX_SETTINGS env var required}"
enabled_plugins="${ENABLED_PLUGINS:?ENABLED_PLUGINS env var required}"

if [ ! -f "$target" ]; then
  existing='{}'
else
  existing="$(cat "$target")"
fi

old_managed='[]'
if [ -f "$managed_keys_file" ]; then
  old_managed="$(cat "$managed_keys_file")"
fi

new_managed="$(echo "$nix_settings" | jq -c '[keys[]] | sort')"

result="$(
  jq -n \
    --argjson existing "$existing" \
    --argjson nix "$nix_settings" \
    --argjson old_managed "$old_managed" \
    --argjson enabled_plugins "$enabled_plugins" \
    '
    ($old_managed - ($nix | keys)) as $stale |
    ($existing | delpaths([$stale[] | [.]])) as $cleaned |
    ($cleaned * $nix) |
    if ($enabled_plugins | length) > 0
    then .enabledPlugins = $enabled_plugins
    else .
    end
  '
)"

mkdir -p "$(dirname "$target")"
tmp="${target}.tmp"
echo "$result" >"$tmp"
mv "$tmp" "$target"

mkdir -p "$(dirname "$managed_keys_file")"
echo "$new_managed" >"$managed_keys_file"
