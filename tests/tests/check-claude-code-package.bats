#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "passes when claude wrapper has DISABLE_AUTOUPDATER" {
  mkdir -p "$TEST_DIR/home-path/bin"
  echo 'DISABLE_AUTOUPDATER=1 exec claude-unwrapped' > "$TEST_DIR/home-path/bin/claude"

  run bash tests/check-claude-code-package.sh "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"passed"* ]]
}

@test "fails when wrapper missing DISABLE_AUTOUPDATER" {
  mkdir -p "$TEST_DIR/home-path/bin"
  echo 'exec claude-unwrapped' > "$TEST_DIR/home-path/bin/claude"

  run bash tests/check-claude-code-package.sh "$TEST_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DISABLE_AUTOUPDATER"* ]]
}

@test "fails when claude binary missing from home-path" {
  mkdir -p "$TEST_DIR/home-path/bin"

  run bash tests/check-claude-code-package.sh "$TEST_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL"* ]]
}

@test "fails when home-path/bin directory missing" {
  mkdir -p "$TEST_DIR"

  run bash tests/check-claude-code-package.sh "$TEST_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL"* ]]
}
