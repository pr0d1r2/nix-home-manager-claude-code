#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR" || exit 1
    git init -q
    git config user.email "test@test.com"
    git config user.name "Test"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "exits silently for non-git-commit commands" {
    run bash -c 'echo "{\"tool_input\":{\"command\":\"ls\"}}" | bash "$0"' \
        "$OLDPWD/files/hooks/coverage-check.sh"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "exits silently when no changed files" {
    echo "init" >file.txt
    git add file.txt
    git commit -q -m "init"

    run bash -c 'echo "{\"tool_input\":{\"command\":\"git commit -m test\"}}" | bash "$0"' \
        "$OLDPWD/files/hooks/coverage-check.sh"
    [ "$status" -eq 0 ]
}

@test "exits silently for coverage-related commits" {
    mkdir -p scripts
    echo '#!/bin/bash' >scripts/deploy.sh
    git add scripts/deploy.sh
    git commit -q -m "test: add coverage for deploy"

    run bash -c 'echo "{\"tool_input\":{\"command\":\"git commit -m test\"}}" | bash "$0"' \
        "$OLDPWD/files/hooks/coverage-check.sh"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "runs coverage.d checkers on git commit" {
    mkdir -p scripts
    echo '#!/bin/bash' >scripts/deploy.sh
    git add scripts/deploy.sh
    git commit -q -m "feat: add deploy script"

    HOOK_SCRIPT="$OLDPWD/files/hooks/coverage-check.sh"
    run bash -c 'echo "{\"tool_input\":{\"command\":\"git commit -m feat\"}}" | bash "$0"' \
        "$HOOK_SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"UNCOVERED_SHELL"* ]] || [ -z "$output" ]
}

@test "handles missing coverage.d directory" {
    echo "init" >file.txt
    git add file.txt
    git commit -q -m "feat: init"

    FAKE_HOOK="$TEST_DIR/fake-coverage-check.sh"
    sed "s|HOOK_DIR=.*|HOOK_DIR=\"$TEST_DIR/nonexistent\"|" \
        "$OLDPWD/files/hooks/coverage-check.sh" >"$FAKE_HOOK"

    run bash -c 'echo "{\"tool_input\":{\"command\":\"git commit -m feat\"}}" | bash "$0"' \
        "$FAKE_HOOK"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
