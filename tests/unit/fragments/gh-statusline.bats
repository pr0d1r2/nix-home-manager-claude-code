#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  export PATH="$TEST_DIR/bin:$PATH"
  mkdir -p "$TEST_DIR/bin"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "outputs nothing when gh not installed" {
  # Shadow any real gh with stub that command -v won't find
  rm -f "$TEST_DIR/bin/gh"
  hash -r 2>/dev/null || true
  if command -v gh >/dev/null 2>&1; then
    skip "gh is installed, cannot test missing-gh path"
  fi
  run bash nix/fragments/gh-statusline.sh
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "outputs green badge when gh authenticated" {
  cat > "$TEST_DIR/bin/gh" <<'SH'
#!/usr/bin/env bash
if [ "$1" = "auth" ] && [ "$2" = "token" ]; then
  echo "gho_fake_token"
  exit 0
fi
SH
  chmod +x "$TEST_DIR/bin/gh"
  run bash nix/fragments/gh-statusline.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[GH]"* ]]
  [[ "$output" == *"38;5;147m"* ]]
}

@test "outputs red badge when gh not authenticated" {
  cat > "$TEST_DIR/bin/gh" <<'SH'
#!/usr/bin/env bash
if [ "$1" = "auth" ] && [ "$2" = "token" ]; then
  exit 1
fi
SH
  chmod +x "$TEST_DIR/bin/gh"
  run bash nix/fragments/gh-statusline.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[GH]"* ]]
  [[ "$output" == *"38;5;196m"* ]]
}
