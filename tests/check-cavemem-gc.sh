#!/usr/bin/env bash
# Regression check for the Node 24.19 ObjectWrap cleanup-hook abort
# (nodejs/node#65446): better-sqlite3 Statement objects collected by an
# allocation-driven GC inside a microtask abort with
# "Assertion failed: (env) != nullptr". cavemem hooks hit it on large
# Stop payloads. Runs the pattern against the packaged node + addon.
set -euo pipefail

PKG="$1"
RUNS="${2:-3}"

NODE=$(grep -o '/nix/store/[^" ]*/bin/node' "$PKG/bin/cavemem" | head -n 1)
ADDON="$PKG/lib/node_modules/cavemem/node_modules/better-sqlite3"

if [ ! -x "$NODE" ]; then
  echo "FAIL: node not found in $PKG/bin/cavemem"
  exit 1
fi

if [ ! -d "$ADDON" ]; then
  echo "FAIL: better-sqlite3 not found at $ADDON"
  exit 1
fi

# shellcheck disable=SC2016
SCRIPT='
const Database = require(process.argv[1]);
const db = new Database(":memory:");
const big = "x".repeat(1 << 16);
(async () => {
  for (let r = 0; r < 3000; r++) {
    await null;
    for (let i = 0; i < 50; i++) db.prepare("select ?").get(i);
    (big + r).match(/x+\d+$/);
  }
})();
'

for run in $(seq 1 "$RUNS"); do
  if ! "$NODE" -e "$SCRIPT" "$ADDON"; then
    echo "FAIL: cavemem node $("$NODE" --version) aborted on GC (run $run/$RUNS)"
    exit 1
  fi
done

echo "cavemem GC check passed ($("$NODE" --version))"
