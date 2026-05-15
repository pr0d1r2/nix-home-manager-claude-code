#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    DATA_DIR="$TEST_DIR/.claude/plugins/data"
    mkdir -p "$DATA_DIR"
    export DATA_DIR
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "removes data dirs not in managed list" {
    mkdir -p "$DATA_DIR/stale-plugin"
    mkdir -p "$DATA_DIR/keep-plugin"

    MANAGED_PLUGINS="keep-plugin" \
        bash lib/clean-plugin-data.sh "$DATA_DIR"

    [ ! -d "$DATA_DIR/stale-plugin" ]
    [ -d "$DATA_DIR/keep-plugin" ]
}

@test "keeps all dirs when all managed" {
    mkdir -p "$DATA_DIR/alpha"
    mkdir -p "$DATA_DIR/beta"

    MANAGED_PLUGINS="alpha beta" \
        bash lib/clean-plugin-data.sh "$DATA_DIR"

    [ -d "$DATA_DIR/alpha" ]
    [ -d "$DATA_DIR/beta" ]
}

@test "no-op when data dir empty" {
    MANAGED_PLUGINS="anything" \
        bash lib/clean-plugin-data.sh "$DATA_DIR"

    [ -d "$DATA_DIR" ]
}

@test "no-op when data dir missing" {
    rmdir "$DATA_DIR"

    MANAGED_PLUGINS="anything" \
        bash lib/clean-plugin-data.sh "$DATA_DIR"

    [ ! -d "$DATA_DIR" ]
}

@test "removes multiple stale dirs" {
    mkdir -p "$DATA_DIR/stale-a"
    mkdir -p "$DATA_DIR/stale-b"
    mkdir -p "$DATA_DIR/keep"

    MANAGED_PLUGINS="keep" \
        bash lib/clean-plugin-data.sh "$DATA_DIR"

    [ ! -d "$DATA_DIR/stale-a" ]
    [ ! -d "$DATA_DIR/stale-b" ]
    [ -d "$DATA_DIR/keep" ]
}

@test "empty managed list removes all dirs" {
    mkdir -p "$DATA_DIR/plugin-a"
    mkdir -p "$DATA_DIR/plugin-b"

    MANAGED_PLUGINS="" \
        bash lib/clean-plugin-data.sh "$DATA_DIR"

    [ ! -d "$DATA_DIR/plugin-a" ]
    [ ! -d "$DATA_DIR/plugin-b" ]
}
