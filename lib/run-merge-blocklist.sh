#!/usr/bin/env bash
set -euo pipefail

export PATH="@jq@:@coreutils@:$PATH"

NIX_BLOCKED="@nixBlocked@" \
    OLD_NIX_BLOCKED="$(cat "$HOME/.claude/.nix-managed-blocked-keys.json" 2>/dev/null || echo '[]')" \
    bash @mergeScript@ \
    "$HOME/.claude/blocklist.json"

echo "@nixBlocked@" >"$HOME/.claude/.nix-managed-blocked-keys.json"
