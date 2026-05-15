#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    CACHE_DIR="$TEST_DIR/.claude/nix-plugins"
    mkdir -p "$CACHE_DIR"
    export CACHE_DIR
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "removes dirs not in managed list" {
    mkdir -p "$CACHE_DIR/stale-market"
    mkdir -p "$CACHE_DIR/keep-market"

    MANAGED_NAMES="keep-market" \
        bash lib/clean-plugin-cache.sh "$CACHE_DIR"

    [ ! -d "$CACHE_DIR/stale-market" ]
    [ -d "$CACHE_DIR/keep-market" ]
}

@test "keeps all dirs when all managed" {
    mkdir -p "$CACHE_DIR/alpha"
    mkdir -p "$CACHE_DIR/beta"

    MANAGED_NAMES="alpha beta" \
        bash lib/clean-plugin-cache.sh "$CACHE_DIR"

    [ -d "$CACHE_DIR/alpha" ]
    [ -d "$CACHE_DIR/beta" ]
}

@test "no-op when cache dir empty" {
    MANAGED_NAMES="anything" \
        bash lib/clean-plugin-cache.sh "$CACHE_DIR"

    [ -d "$CACHE_DIR" ]
}

@test "no-op when cache dir missing" {
    rmdir "$CACHE_DIR"

    MANAGED_NAMES="anything" \
        bash lib/clean-plugin-cache.sh "$CACHE_DIR"

    [ ! -d "$CACHE_DIR" ]
}

@test "removes multiple stale dirs" {
    mkdir -p "$CACHE_DIR/stale-a"
    mkdir -p "$CACHE_DIR/stale-b"
    mkdir -p "$CACHE_DIR/keep"

    MANAGED_NAMES="keep" \
        bash lib/clean-plugin-cache.sh "$CACHE_DIR"

    [ ! -d "$CACHE_DIR/stale-a" ]
    [ ! -d "$CACHE_DIR/stale-b" ]
    [ -d "$CACHE_DIR/keep" ]
}

@test "empty managed list removes all dirs" {
    mkdir -p "$CACHE_DIR/market-a"
    mkdir -p "$CACHE_DIR/market-b"

    MANAGED_NAMES="" \
        bash lib/clean-plugin-cache.sh "$CACHE_DIR"

    [ ! -d "$CACHE_DIR/market-a" ]
    [ ! -d "$CACHE_DIR/market-b" ]
}
