#!/usr/bin/env bash
set -euo pipefail

export PATH="@coreutils@:$PATH"

MANAGED_PLUGINS="@managedPlugins@" \
    bash @cleanScript@ \
    "$HOME/.claude/plugins/data"
