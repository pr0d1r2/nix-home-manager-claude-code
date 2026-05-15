#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  SCRIPT="$TEST_DIR/semble-statusline.sh"
  mkdir -p "$TEST_DIR/bin"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "outputs badge when semble binary executable" {
  cat > "$TEST_DIR/bin/mock-semble" <<'SH'
#!/usr/bin/env bash
echo "semble"
SH
  chmod +x "$TEST_DIR/bin/mock-semble"
  sed "s|@semble@|$TEST_DIR/bin/mock-semble|g" nix/fragments/semble-statusline.sh > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[SEMBLE]"* ]]
  [[ "$output" == *"38;5;220m"* ]]
}

@test "outputs nothing when semble not executable" {
  sed "s|@semble@|/nonexistent/semble|g" nix/fragments/semble-statusline.sh > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
