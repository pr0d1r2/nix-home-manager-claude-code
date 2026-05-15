#!/usr/bin/env bats

setup() {
  SCRIPT_DIR="$PWD"
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR" || exit
  git init -q
  git commit --allow-empty -m "init" -q
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "shows branch name" {
  run bash "$OLDPWD/nix/fragments/git-status-statusline.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"git:"* ]]
  [[ "$output" == *"main"* ]] || [[ "$output" == *"master"* ]]
}

@test "shows dirty marker for uncommitted changes" {
  echo "dirty" > file.txt
  git add file.txt
  run bash "$OLDPWD/nix/fragments/git-status-statusline.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"*"* ]]
}

@test "no dirty marker on clean repo" {
  run bash "$OLDPWD/nix/fragments/git-status-statusline.sh"
  [ "$status" -eq 0 ]
  [[ "$output" != *"*"* ]]
}

@test "exits silently outside git repo" {
  nogit="$(mktemp -d)"
  cd "$nogit"
  GIT_DIR='' GIT_WORK_TREE='' run bash "$SCRIPT_DIR/nix/fragments/git-status-statusline.sh"
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
  rm -rf "$nogit"
}

@test "uses green color code" {
  run bash "$OLDPWD/nix/fragments/git-status-statusline.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"38;5;2m"* ]]
}

@test "shows detached HEAD as short hash" {
  hash="$(git rev-parse --short HEAD)"
  git checkout -q --detach HEAD
  run bash "$OLDPWD/nix/fragments/git-status-statusline.sh"
  [ "$status" -eq 0 ]
  [[ "$output" == *"$hash"* ]]
}
