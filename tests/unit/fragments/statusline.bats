#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  export HOME="$TEST_DIR"
  mkdir -p "$TEST_DIR/.claude/hooks"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "outputs nothing when no statusline hooks exist" {
  run bash nix/fragments/statusline.sh
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "collects output from single statusline hook" {
  cat > "$TEST_DIR/.claude/hooks/foo-statusline.sh" <<'SH'
#!/bin/sh
printf '[FOO]'
SH
  run bash nix/fragments/statusline.sh
  [ "$status" -eq 0 ]
  [ "$output" = "[FOO]" ]
}

@test "collects output from multiple hooks on left" {
  cat > "$TEST_DIR/.claude/hooks/aaa-statusline.sh" <<'SH'
#!/bin/sh
printf '[AAA]'
SH
  cat > "$TEST_DIR/.claude/hooks/bbb-statusline.sh" <<'SH'
#!/bin/sh
printf '[BBB]'
SH
  run bash nix/fragments/statusline.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"[AAA]"* ]]
  [[ "$output" == *"[BBB]"* ]]
}

@test "git-status-statusline goes to right side" {
  cat > "$TEST_DIR/.claude/hooks/foo-statusline.sh" <<'SH'
#!/bin/sh
printf '[FOO]'
SH
  cat > "$TEST_DIR/.claude/hooks/git-status-statusline.sh" <<'SH'
#!/bin/sh
printf '(git:main)'
SH
  run bash nix/fragments/statusline.sh
  [ "$status" -eq 0 ]
  [ "$output" = "[FOO]  (git:main)" ]
}

@test "only right side when no left hooks" {
  cat > "$TEST_DIR/.claude/hooks/git-status-statusline.sh" <<'SH'
#!/bin/sh
printf '(git:main)'
SH
  run bash nix/fragments/statusline.sh
  [ "$status" -eq 0 ]
  [ "$output" = "(git:main)" ]
}

@test "skips hooks with empty output" {
  cat > "$TEST_DIR/.claude/hooks/empty-statusline.sh" <<'SH'
#!/bin/sh
SH
  cat > "$TEST_DIR/.claude/hooks/foo-statusline.sh" <<'SH'
#!/bin/sh
printf '[FOO]'
SH
  run bash nix/fragments/statusline.sh
  [ "$status" -eq 0 ]
  [ "$output" = "[FOO]" ]
}

@test "skips hooks that fail" {
  cat > "$TEST_DIR/.claude/hooks/bad-statusline.sh" <<'SH'
#!/bin/sh
exit 1
SH
  cat > "$TEST_DIR/.claude/hooks/foo-statusline.sh" <<'SH'
#!/bin/sh
printf '[FOO]'
SH
  run bash nix/fragments/statusline.sh
  [ "$status" -eq 0 ]
  [ "$output" = "[FOO]" ]
}
