#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  SCRIPT="$TEST_DIR/caveman-activate-wrapper.sh"
  sed -e "s|@node@|$TEST_DIR/bin/mock-node|g" \
      -e "s|@hooks@|$TEST_DIR/hooks|g" \
      nix/fragments/caveman-activate-wrapper.sh > "$SCRIPT"
  mkdir -p "$TEST_DIR/bin" "$TEST_DIR/hooks"
  cat > "$TEST_DIR/bin/mock-node" <<'SH'
#!/bin/sh
echo "node called: $*"
SH
  chmod +x "$TEST_DIR/bin/mock-node"
  touch "$TEST_DIR/hooks/caveman-activate.js"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "calls node with caveman-activate.js" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"caveman-activate.js"* ]]
}

@test "passes hooks path from placeholder" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$TEST_DIR/hooks/caveman-activate.js"* ]]
}
