#!/usr/bin/env bats

setup() {
    export TEST_DIR
    TEST_DIR="$(mktemp -d)"
    export SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../scripts" && pwd)"
}

teardown() {
    rm -rf "$TEST_DIR"
}

write_lock() {
    cat > "$TEST_DIR/flake.lock"
}

@test "passes when repo is locked once" {
    write_lock <<'JSON'
{"nodes":{"root":{"inputs":{"rtk-src":"rtk-src"}},
"rtk-src":{"original":{"owner":"rtk-ai","repo":"rtk","type":"github"}}}}
JSON
    run bash "$SCRIPT_DIR/check-lock-unique.sh" "$TEST_DIR/flake.lock" rtk-ai/rtk
    [ "$status" -eq 0 ]
}

@test "passes when repo is absent" {
    write_lock <<'JSON'
{"nodes":{"root":{"inputs":{}}}}
JSON
    run bash "$SCRIPT_DIR/check-lock-unique.sh" "$TEST_DIR/flake.lock" rtk-ai/rtk
    [ "$status" -eq 0 ]
}

@test "fails and names nodes when repo is locked twice" {
    write_lock <<'JSON'
{"nodes":{"root":{"inputs":{}},
"rtk-src":{"original":{"owner":"rtk-ai","repo":"rtk","type":"github"}},
"rtk-src_2":{"original":{"owner":"rtk-ai","repo":"rtk","type":"github"}}}}
JSON
    run bash "$SCRIPT_DIR/check-lock-unique.sh" "$TEST_DIR/flake.lock" rtk-ai/rtk
    [ "$status" -eq 1 ]
    [[ "$output" == *"rtk-ai/rtk locked 2 times"* ]]
    [[ "$output" == *"rtk-src_2"* ]]
}

@test "checks every repo given" {
    write_lock <<'JSON'
{"nodes":{"root":{"inputs":{}},
"a":{"original":{"owner":"o","repo":"a","type":"github"}},
"b":{"original":{"owner":"o","repo":"b","type":"github"}},
"b_2":{"original":{"owner":"o","repo":"b","type":"github"}}}}
JSON
    run bash "$SCRIPT_DIR/check-lock-unique.sh" "$TEST_DIR/flake.lock" o/a o/b
    [ "$status" -eq 1 ]
    [[ "$output" == *"o/b locked 2 times"* ]]
    [[ "$output" != *"o/a"* ]]
}

@test "ignores owner case" {
    write_lock <<'JSON'
{"nodes":{"root":{"inputs":{}},
"x":{"original":{"owner":"RTK-AI","repo":"rtk","type":"github"}},
"y":{"original":{"owner":"rtk-ai","repo":"rtk","type":"github"}}}}
JSON
    run bash "$SCRIPT_DIR/check-lock-unique.sh" "$TEST_DIR/flake.lock" rtk-ai/rtk
    [ "$status" -eq 1 ]
}

@test "fails with usage when no repo given" {
    write_lock <<'JSON'
{"nodes":{}}
JSON
    run bash "$SCRIPT_DIR/check-lock-unique.sh" "$TEST_DIR/flake.lock"
    [ "$status" -eq 2 ]
    [[ "$output" == *"usage"* ]]
}

@test "fails when lock file missing" {
    run bash "$SCRIPT_DIR/check-lock-unique.sh" "$TEST_DIR/nope.lock" rtk-ai/rtk
    [ "$status" -eq 2 ]
}
