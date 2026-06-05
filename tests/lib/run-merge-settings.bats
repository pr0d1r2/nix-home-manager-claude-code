#!/usr/bin/env bats

SRC="lib/run-merge-settings.sh"

@test "NIX_SETTINGS uses single quotes to prevent JSON double-quote breakage" {
  grep -q "NIX_SETTINGS='@nixSettings@'" "$SRC"
}

@test "ENABLED_PLUGINS uses single quotes to prevent JSON double-quote breakage" {
  grep -q "ENABLED_PLUGINS='@enabledPlugins@'" "$SRC"
}
