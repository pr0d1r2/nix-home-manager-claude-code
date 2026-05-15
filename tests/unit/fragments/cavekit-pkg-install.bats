#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  SRC_DIR="$TEST_DIR/src"
  export out="$TEST_DIR/out"
  mkdir -p "$SRC_DIR/commands" "$SRC_DIR/skills" "$SRC_DIR/.claude-plugin"
  echo '{}' > "$SRC_DIR/plugin.json"
  echo '# fmt' > "$SRC_DIR/FORMAT.md"
  echo 'cmd1' > "$SRC_DIR/commands/test.md"
  echo 'skill1' > "$SRC_DIR/skills/test.md"
  echo 'plugin' > "$SRC_DIR/.claude-plugin/config"
  cd "$SRC_DIR" || exit
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "creates output directories" {
  bash "$OLDPWD/nix/fragments/cavekit-pkg-install.sh"
  [ -d "$out/commands" ]
  [ -d "$out/skills" ]
}

@test "copies plugin.json" {
  bash "$OLDPWD/nix/fragments/cavekit-pkg-install.sh"
  [ -f "$out/plugin.json" ]
}

@test "copies FORMAT.md" {
  bash "$OLDPWD/nix/fragments/cavekit-pkg-install.sh"
  [ -f "$out/FORMAT.md" ]
}

@test "copies commands directory" {
  bash "$OLDPWD/nix/fragments/cavekit-pkg-install.sh"
  [ -f "$out/commands/test.md" ]
}

@test "copies skills directory" {
  bash "$OLDPWD/nix/fragments/cavekit-pkg-install.sh"
  [ -f "$out/skills/test.md" ]
}

@test "copies .claude-plugin directory" {
  bash "$OLDPWD/nix/fragments/cavekit-pkg-install.sh"
  [ -f "$out/.claude-plugin/config" ]
}
