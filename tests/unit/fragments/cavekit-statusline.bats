#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR" || exit
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "outputs badge when SPEC.md exists" {
  touch SPEC.md
  run bash "$OLDPWD/nix/fragments/cavekit-statusline.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[CAVEKIT]"* ]]
  [[ "$output" == *"38;5;172m"* ]]
}

@test "outputs nothing when SPEC.md absent" {
  run bash "$OLDPWD/nix/fragments/cavekit-statusline.sh"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
