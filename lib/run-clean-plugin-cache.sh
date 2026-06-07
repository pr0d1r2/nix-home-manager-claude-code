#!/usr/bin/env bash
set -euo pipefail

export PATH="@coreutils@:$PATH"

MANAGED_NAMES="@managedNames@" \
  bash @cleanScript@ \
  "$HOME/.claude/nix-plugins"
