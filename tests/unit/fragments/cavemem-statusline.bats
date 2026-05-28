#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  export HOME="$TEST_DIR"
  SCRIPT="$TEST_DIR/cavemem-statusline.sh"
  mkdir -p "$TEST_DIR/bin"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "outputs nothing when cavemem unavailable" {
  sed "s|@cavemem@|/nonexistent/cavemem|g" nix/fragments/cavemem-statusline.sh > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "outputs green badge when worker running" {
  cat > "$TEST_DIR/bin/mock-cavemem" <<'SH'
#!/bin/sh
exit 0
SH
  chmod +x "$TEST_DIR/bin/mock-cavemem"
  mkdir -p "$TEST_DIR/.cavemem"
  echo "$$" > "$TEST_DIR/.cavemem/worker.pid"
  sed "s|@cavemem@|$TEST_DIR/bin/mock-cavemem|g" nix/fragments/cavemem-statusline.sh > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[CAVEMEM]"* ]]
  [[ "$output" == *"38;5;172m"* ]]
}

@test "outputs red badge when worker not running" {
  cat > "$TEST_DIR/bin/mock-cavemem" <<'SH'
#!/bin/sh
exit 0
SH
  chmod +x "$TEST_DIR/bin/mock-cavemem"
  mkdir -p "$TEST_DIR/.cavemem"
  echo "99999999" > "$TEST_DIR/.cavemem/worker.pid"
  sed "s|@cavemem@|$TEST_DIR/bin/mock-cavemem|g" nix/fragments/cavemem-statusline.sh > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[CAVEMEM]"* ]]
  [[ "$output" == *"38;5;196m"* ]]
}

@test "outputs red badge when no pid file" {
  cat > "$TEST_DIR/bin/mock-cavemem" <<'SH'
#!/bin/sh
exit 0
SH
  chmod +x "$TEST_DIR/bin/mock-cavemem"
  sed "s|@cavemem@|$TEST_DIR/bin/mock-cavemem|g" nix/fragments/cavemem-statusline.sh > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[CAVEMEM]"* ]]
  [[ "$output" == *"38;5;196m"* ]]
}
