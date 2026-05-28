#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  SCRIPT="$TEST_DIR/astfold-statusline.sh"
  mkdir -p "$TEST_DIR/bin"
  cd "$TEST_DIR" || exit
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "outputs nothing when fast unavailable" {
  sed "s|@fast@|/nonexistent/fast|g" "$OLDPWD/nix/fragments/astfold-statusline.sh" > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "outputs badge when fast available and .rb files exist" {
  cat > "$TEST_DIR/bin/mock-fast" <<'SH'
#!/usr/bin/env bash
exit 0
SH
  chmod +x "$TEST_DIR/bin/mock-fast"
  touch "$TEST_DIR/app.rb"
  sed "s|@fast@|$TEST_DIR/bin/mock-fast|g" "$OLDPWD/nix/fragments/astfold-statusline.sh" > "$SCRIPT"
  run bash -x "$SCRIPT"
  [ "$status" -eq 0 ]
  [[ "$output" == *"[ASTFOLD]"* ]]
  [[ "$output" == *"38;5;82m"* ]]
}

@test "outputs nothing when fast available but no .rb files" {
  cat > "$TEST_DIR/bin/mock-fast" <<'SH'
#!/usr/bin/env bash
exit 0
SH
  chmod +x "$TEST_DIR/bin/mock-fast"
  sed "s|@fast@|$TEST_DIR/bin/mock-fast|g" "$OLDPWD/nix/fragments/astfold-statusline.sh" > "$SCRIPT"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}
