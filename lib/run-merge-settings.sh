#!/usr/bin/env bash
set -euo pipefail

export PATH="@jq@:@coreutils@:$PATH"

NIX_SETTINGS="@nixSettings@" \
    ENABLED_PLUGINS="@enabledPlugins@" \
    bash @mergeScript@ \
    "$HOME/.claude/settings.json" \
    "$HOME/.claude/.nix-managed-keys.json"
