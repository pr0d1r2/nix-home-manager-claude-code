#!/usr/bin/env bash
set -euo pipefail

export PATH="@jq@:@coreutils@:$PATH"

NIX_SETTINGS=$(
    cat <<'__NIX_JSON_EOF__'
@nixSettings@
__NIX_JSON_EOF__
) \
ENABLED_PLUGINS=$(
    cat <<'__NIX_JSON_EOF__'
@enabledPlugins@
__NIX_JSON_EOF__
) \
    bash @mergeScript@ \
    "$HOME/.claude/settings.json" \
    "$HOME/.claude/.nix-managed-keys.json"
