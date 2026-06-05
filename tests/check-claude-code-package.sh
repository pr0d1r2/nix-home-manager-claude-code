#!/usr/bin/env bash
set -euo pipefail

GEN="$1"
HOME_PATH="$GEN/home-path"

if [ ! -e "$HOME_PATH/bin/claude" ]; then
    echo "FAIL: claude binary not in home-path"
    exit 1
fi

echo "Claude Code package integration check passed"
