#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR" || exit 1
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "flags .sh file without matching .bats" {
    mkdir -p scripts
    echo '#!/bin/bash' >scripts/deploy.sh

    run bash "$OLDPWD/files/hooks/coverage.d/shell.sh" "scripts/deploy.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"UNCOVERED_SHELL"* ]]
    [[ "$output" == *"scripts/deploy.sh"* ]]
}

@test "passes when .bats test exists in test/" {
    mkdir -p scripts test
    echo '#!/bin/bash' >scripts/deploy.sh
    echo '@test "x" { true; }' >test/deploy.bats

    run bash "$OLDPWD/files/hooks/coverage.d/shell.sh" "scripts/deploy.sh"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "passes when test references script name" {
    mkdir -p scripts test
    echo '#!/bin/bash' >scripts/deploy.sh
    echo 'bash scripts/deploy.sh' >test/other.bats

    run bash "$OLDPWD/files/hooks/coverage.d/shell.sh" "scripts/deploy.sh"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "ignores non-.sh files" {
    run bash "$OLDPWD/files/hooks/coverage.d/shell.sh" "src/main.py"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "ignores deleted .sh files" {
    run bash "$OLDPWD/files/hooks/coverage.d/shell.sh" "scripts/gone.sh"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "detects parent-based naming convention" {
    mkdir -p scripts/iso test
    echo '#!/bin/bash' >scripts/iso/build.sh
    echo '@test "x" { true; }' >test/iso.bats

    run bash "$OLDPWD/files/hooks/coverage.d/shell.sh" "scripts/iso/build.sh"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "suggests /cover-sh for non-ruby projects" {
    mkdir -p scripts
    echo '#!/bin/bash' >scripts/deploy.sh

    run bash "$OLDPWD/files/hooks/coverage.d/shell.sh" "scripts/deploy.sh"
    [[ "$output" == *"/cover-sh"* ]]
}

@test "suggests /cover-rb for ruby projects" {
    mkdir -p scripts
    echo '#!/bin/bash' >scripts/deploy.sh
    touch Gemfile

    run bash "$OLDPWD/files/hooks/coverage.d/shell.sh" "scripts/deploy.sh"
    [[ "$output" == *"/cover-rb"* ]]
}
