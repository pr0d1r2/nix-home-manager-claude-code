#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  SRC_DIR="$TEST_DIR/src"
  export out="$TEST_DIR/out"
  mkdir -p "$SRC_DIR/hooks" "$SRC_DIR/skills/caveman"
  echo '{}' > "$SRC_DIR/hooks/package.json"
  echo 'config' > "$SRC_DIR/hooks/caveman-config.js"
  echo 'activate' > "$SRC_DIR/hooks/caveman-activate.js"
  echo 'tracker' > "$SRC_DIR/hooks/caveman-mode-tracker.js"
  echo '#!/usr/bin/env bash' > "$SRC_DIR/hooks/caveman-statusline.sh"
  echo 'skill' > "$SRC_DIR/skills/caveman/SKILL.md"
  cd "$SRC_DIR" || exit
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "creates output directories" {
  bash "$OLDPWD/nix/fragments/caveman-pkg-install.sh"
  [ -d "$out/hooks" ]
  [ -d "$out/skills/caveman" ]
}

@test "copies hook files" {
  bash "$OLDPWD/nix/fragments/caveman-pkg-install.sh"
  [ -f "$out/hooks/package.json" ]
  [ -f "$out/hooks/caveman-config.js" ]
  [ -f "$out/hooks/caveman-activate.js" ]
  [ -f "$out/hooks/caveman-mode-tracker.js" ]
}

@test "copies and makes statusline executable" {
  bash "$OLDPWD/nix/fragments/caveman-pkg-install.sh"
  [ -f "$out/hooks/caveman-statusline.sh" ]
  [ -x "$out/hooks/caveman-statusline.sh" ]
}

@test "copies skill file" {
  bash "$OLDPWD/nix/fragments/caveman-pkg-install.sh"
  [ -f "$out/skills/caveman/SKILL.md" ]
}
