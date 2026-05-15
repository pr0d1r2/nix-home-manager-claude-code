#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  SCRIPT="$TEST_DIR/rtk-statusline.sh"
  mkdir -p "$TEST_DIR/bin"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "outputs badge when rtk available" {
  cat > "$TEST_DIR/bin/mock-rtk" <<'SH'
#!/usr/bin/env bash
echo "rtk 1.0.0"
SH
  chmod +x "$TEST_DIR/bin/mock-rtk"
  sed "s|@rtk@|$TEST_DIR/bin/mock-rtk|g" nix/fragments/rtk-statusline.sh > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[RTK]"* ]]
  [[ "$output" == *"38;5;51m"* ]]
}

@test "outputs nothing when rtk unavailable" {
  sed "s|@rtk@|/nonexistent/rtk|g" nix/fragments/rtk-statusline.sh > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
