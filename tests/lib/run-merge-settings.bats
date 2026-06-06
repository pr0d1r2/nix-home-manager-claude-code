#!/usr/bin/env bats

SRC="lib/run-merge-settings.sh"

@test "NIX_SETTINGS uses heredoc to safely embed JSON" {
  grep -q "cat <<'__NIX_JSON_EOF__'" "$SRC"
  grep -q '@nixSettings@' "$SRC"
}

@test "no bare single or double quoted JSON vars" {
  run ! grep -qE "NIX_SETTINGS=['\"]@" "$SRC"
  run ! grep -qE "ENABLED_PLUGINS=['\"]@" "$SRC"
}
