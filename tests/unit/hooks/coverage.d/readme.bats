#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR" || exit 1
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "skips when no README.md" {
    run bash "$OLDPWD/files/hooks/coverage.d/readme.sh" ""
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "passes when README has no hardcoded counts" {
    echo "# My Project" >README.md
    echo "Some description." >>README.md

    run bash "$OLDPWD/files/hooks/coverage.d/readme.sh" ""
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "detects wrong module count" {
    mkdir modules
    touch modules/a.nix modules/b.nix
    echo "We have 5 NixOS modules" >README.md

    run bash "$OLDPWD/files/hooks/coverage.d/readme.sh" ""
    [ "$status" -eq 0 ]
    [[ "$output" == *"README_DRIFT"* ]]
    [[ "$output" == *"NixOS modules"* ]]
}

@test "passes when module count matches" {
    mkdir modules
    touch modules/a.nix modules/b.nix
    echo "We have 2 NixOS modules" >README.md

    run bash "$OLDPWD/files/hooks/coverage.d/readme.sh" ""
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
