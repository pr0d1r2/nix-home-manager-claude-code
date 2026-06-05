#!/usr/bin/env bats

SRC="lib/run-merge-blocklist.sh"

@test "NIX_BLOCKED uses single quotes to prevent JSON double-quote breakage" {
  grep -q "NIX_BLOCKED='@nixBlocked@'" "$SRC"
}

@test "echo of nixBlocked uses single quotes" {
  grep -q "echo '@nixBlocked@'" "$SRC"
}
