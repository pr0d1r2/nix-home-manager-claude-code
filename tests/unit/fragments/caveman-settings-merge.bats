#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  export CLAUDE_CONFIG_DIR="$TEST_DIR"
  SCRIPT="$TEST_DIR/caveman-settings-merge.sh"
  sed "s|@jq@|jq|g" nix/fragments/caveman-settings-merge.sh > "$SCRIPT"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "exits silently when settings.json absent" {
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_DIR/settings.json" ]
}

@test "adds caveman hooks to empty settings" {
  echo '{}' > "$TEST_DIR/settings.json"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  result="$(jq '.hooks.SessionStart | length' "$TEST_DIR/settings.json")"
  [ "$result" -eq 1 ]
  result="$(jq '.hooks.UserPromptSubmit | length' "$TEST_DIR/settings.json")"
  [ "$result" -eq 1 ]
}

@test "adds statusLine when not present" {
  echo '{}' > "$TEST_DIR/settings.json"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  result="$(jq -r '.statusLine.command' "$TEST_DIR/settings.json")"
  [[ "$result" == *"statusline.sh"* ]]
}

@test "preserves existing statusLine" {
  echo '{"statusLine":{"type":"command","command":"custom.sh"}}' > "$TEST_DIR/settings.json"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  result="$(jq -r '.statusLine.command' "$TEST_DIR/settings.json")"
  [ "$result" = "custom.sh" ]
}

@test "skips when caveman-activate already configured" {
  echo '{"hooks":{"SessionStart":[{"hooks":[{"type":"command","command":"bash ~/.claude/hooks/caveman-activate.sh"}]}]}}' > "$TEST_DIR/settings.json"
  cp "$TEST_DIR/settings.json" "$TEST_DIR/settings-before.json"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  diff "$TEST_DIR/settings.json" "$TEST_DIR/settings-before.json"
}

@test "preserves existing settings keys" {
  echo '{"model":"opus","theme":"dark"}' > "$TEST_DIR/settings.json"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  result="$(jq -r '.model' "$TEST_DIR/settings.json")"
  [ "$result" = "opus" ]
  result="$(jq -r '.theme' "$TEST_DIR/settings.json")"
  [ "$result" = "dark" ]
}

@test "atomic write via tmp file" {
  echo '{}' > "$TEST_DIR/settings.json"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ ! -f "$TEST_DIR/settings.json.tmp" ]
}
