#!/usr/bin/env bash
set -euo pipefail

PKG="$1"

if [ ! -e "$PKG/bin/claude" ]; then
  echo "FAIL: claude binary not found at $PKG/bin/claude"
  exit 1
fi

if [ ! -x "$PKG/bin/claude" ]; then
  echo "FAIL: claude binary not executable"
  exit 1
fi

if ! grep -q "DISABLE_AUTOUPDATER" "$PKG/bin/claude" 2>/dev/null; then
  echo "FAIL: wrapper missing DISABLE_AUTOUPDATER"
  exit 1
fi

echo "Claude Code binary check passed"
