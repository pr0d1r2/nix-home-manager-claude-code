#!/usr/bin/env bash
set -euo pipefail

target="${1:?usage: merge-blocklist.sh TARGET}"
nix_blocked="${NIX_BLOCKED:?NIX_BLOCKED env var required}"
old_nix_blocked="${OLD_NIX_BLOCKED:-[]}"

if [ ! -f "$target" ]; then
    existing='[]'
else
    existing="$(cat "$target")"
fi

result="$(
    jq -n \
        --argjson existing "$existing" \
        --argjson nix "$nix_blocked" \
        --argjson old_nix "$old_nix_blocked" \
        '
    ($existing - $old_nix) + $nix | unique
  '
)"

mkdir -p "$(dirname "$target")"
tmp="${target}.tmp"
echo "$result" >"$tmp"
mv "$tmp" "$target"
