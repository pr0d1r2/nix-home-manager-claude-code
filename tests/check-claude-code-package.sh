#!/usr/bin/env bash
set -euo pipefail

GEN="$1"
HOME_PATH="$GEN/home-path"

if [ ! -e "$HOME_PATH/bin/claude" ]; then
    echo "FAIL: claude binary not in home-path"
    exit 1
fi

wrapper="$HOME_PATH/bin/claude"
if [ -L "$wrapper" ]; then
    wrapper="$(readlink -f "$wrapper")"
fi

if ! grep -q "DISABLE_AUTOUPDATER" "$wrapper" 2>/dev/null; then
    echo "FAIL: wrapper missing DISABLE_AUTOUPDATER"
    exit 1
fi

echo "Claude Code package integration check passed"
