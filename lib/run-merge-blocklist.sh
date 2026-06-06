#!/usr/bin/env bash
set -euo pipefail

export PATH="@jq@:@coreutils@:$PATH"

NIX_BLOCKED=$(
    cat <<'__NIX_JSON_EOF__'
@nixBlocked@
__NIX_JSON_EOF__
) \
OLD_NIX_BLOCKED="$(cat "$HOME/.claude/.nix-managed-blocked-keys.json" 2>/dev/null || echo '[]')" \
    bash @mergeScript@ \
    "$HOME/.claude/blocklist.json"

mkdir -p "$HOME/.claude"
cat <<'__NIX_JSON_EOF__' >"$HOME/.claude/.nix-managed-blocked-keys.json"
@nixBlocked@
__NIX_JSON_EOF__
