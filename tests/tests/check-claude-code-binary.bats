#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "passes when binary exists with correct wrapper env vars" {
  mkdir -p "$TEST_DIR/bin"
  printf 'DISABLE_AUTOUPDATER=1\nexec claude-unwrapped' > "$TEST_DIR/bin/claude"
  chmod +x "$TEST_DIR/bin/claude"

  run bash tests/check-claude-code-binary.sh "$TEST_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"passed"* ]]
}

@test "fails when claude binary missing" {
  mkdir -p "$TEST_DIR/bin"

  run bash tests/check-claude-code-binary.sh "$TEST_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL"* ]]
}

@test "fails when binary not executable" {
  mkdir -p "$TEST_DIR/bin"
  printf 'DISABLE_AUTOUPDATER=1' > "$TEST_DIR/bin/claude"
  chmod -x "$TEST_DIR/bin/claude"

  run bash tests/check-claude-code-binary.sh "$TEST_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not executable"* ]]
}

@test "fails when wrapper missing DISABLE_AUTOUPDATER" {
  mkdir -p "$TEST_DIR/bin"
  printf 'exec claude-unwrapped' > "$TEST_DIR/bin/claude"
  chmod +x "$TEST_DIR/bin/claude"

  run bash tests/check-claude-code-binary.sh "$TEST_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"DISABLE_AUTOUPDATER"* ]]
}

@test "fails when bin directory missing" {
  run bash tests/check-claude-code-binary.sh "$TEST_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"FAIL"* ]]
}
