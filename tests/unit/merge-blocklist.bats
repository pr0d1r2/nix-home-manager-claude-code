#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    TARGET="$TEST_DIR/blocklist.json"
    export TARGET
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "creates blocklist.json when absent" {
    NIX_BLOCKED='["bad@market"]' \
        bash lib/merge-blocklist.sh "$TARGET"

    [ -f "$TARGET" ]
    result="$(jq -c '.' "$TARGET")"
    [ "$result" = '["bad@market"]' ]
}

@test "adds nix entries to existing blocklist" {
    echo '["manual@market"]' >"$TARGET"

    NIX_BLOCKED='["nix@market"]' \
        bash lib/merge-blocklist.sh "$TARGET"

    result="$(jq -c 'sort' "$TARGET")"
    [ "$result" = '["manual@market","nix@market"]' ]
}

@test "preserves manually blocked plugins" {
    echo '["manual@market"]' >"$TARGET"

    NIX_BLOCKED='["nix@market"]' \
        bash lib/merge-blocklist.sh "$TARGET"

    [ "$(jq 'index("manual@market") != null' "$TARGET")" = "true" ]
}

@test "removes stale nix entries" {
    echo '["old-nix@market","manual@market"]' >"$TARGET"

    NIX_BLOCKED='["new-nix@market"]' \
    OLD_NIX_BLOCKED='["old-nix@market"]' \
        bash lib/merge-blocklist.sh "$TARGET"

    [ "$(jq 'index("old-nix@market") != null' "$TARGET")" = "false" ]
    [ "$(jq 'index("manual@market") != null' "$TARGET")" = "true" ]
    [ "$(jq 'index("new-nix@market") != null' "$TARGET")" = "true" ]
}

@test "idempotent on repeated runs" {
    NIX_BLOCKED='["a@m"]' \
        bash lib/merge-blocklist.sh "$TARGET"
    first="$(cat "$TARGET")"

    NIX_BLOCKED='["a@m"]' \
    OLD_NIX_BLOCKED='["a@m"]' \
        bash lib/merge-blocklist.sh "$TARGET"
    second="$(cat "$TARGET")"

    [ "$first" = "$second" ]
}

@test "empty nix blocked list" {
    echo '["manual@market"]' >"$TARGET"

    NIX_BLOCKED='[]' \
        bash lib/merge-blocklist.sh "$TARGET"

    result="$(jq -c '.' "$TARGET")"
    [ "$result" = '["manual@market"]' ]
}

@test "atomic write via tmp file" {
    NIX_BLOCKED='["x@m"]' \
        bash lib/merge-blocklist.sh "$TARGET"

    [ -f "$TARGET" ]
    [ ! -f "${TARGET}.tmp" ]
}
