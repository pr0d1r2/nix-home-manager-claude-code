#!/usr/bin/env bats

setup() {
    export TEST_DIR
    TEST_DIR="$(mktemp -d)"
    export CACHE_DIR="$TEST_DIR/plugins/cache"
    mkdir -p "$CACHE_DIR"
    export SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../scripts" && pwd)"
}

teardown() {
    rm -rf "$TEST_DIR"
}

create_plugin() {
    local name="$1"
    local version="$2"
    local desc="$3"
    local dir="$CACHE_DIR/$name/$name/$version/.claude-plugin"
    mkdir -p "$dir"
    cat > "$dir/plugin.json" <<PJSON
{
  "name": "$name",
  "version": "$version",
  "description": "$desc"
}
PJSON
}

create_marketplace_plugin() {
    local marketplace="$1"
    local name="$2"
    local version="$3"
    local desc="$4"
    local dir="$CACHE_DIR/$marketplace/$name/$version/.claude-plugin"
    mkdir -p "$dir"
    cat > "$dir/plugin.json" <<PJSON
{
  "name": "$name",
  "version": "$version",
  "description": "$desc"
}
PJSON
}

@test "outputs nix snippet for detected plugin" {
    create_plugin "test-plugin" "1.0.0" "A test plugin"

    run bash "$SCRIPT_DIR/detect-plugins.sh" --cache-dir "$CACHE_DIR"

    [ "$status" -eq 0 ]
    [[ "$output" == *"test-plugin"* ]]
    [[ "$output" == *"src"* ]]
}

@test "outputs json with --json flag" {
    create_plugin "test-plugin" "1.0.0" "A test plugin"

    run bash "$SCRIPT_DIR/detect-plugins.sh" --json --cache-dir "$CACHE_DIR"

    [ "$status" -eq 0 ]
    echo "$output" | jq . >/dev/null 2>&1
}

@test "detects multiple plugins" {
    create_plugin "plugin-a" "1.0.0" "Plugin A"
    create_plugin "plugin-b" "2.0.0" "Plugin B"

    run bash "$SCRIPT_DIR/detect-plugins.sh" --cache-dir "$CACHE_DIR"

    [ "$status" -eq 0 ]
    [[ "$output" == *"plugin-a"* ]]
    [[ "$output" == *"plugin-b"* ]]
}

@test "detects marketplace sub-plugins" {
    create_marketplace_plugin "my-marketplace" "sub-plugin" "3.0.0" "Sub plugin"

    run bash "$SCRIPT_DIR/detect-plugins.sh" --cache-dir "$CACHE_DIR"

    [ "$status" -eq 0 ]
    [[ "$output" == *"sub-plugin"* ]]
}

@test "empty cache produces no output" {
    run bash "$SCRIPT_DIR/detect-plugins.sh" --cache-dir "$CACHE_DIR"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "handles missing cache directory" {
    run bash "$SCRIPT_DIR/detect-plugins.sh" --cache-dir "$TEST_DIR/nonexistent"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "json output has name and path fields" {
    create_plugin "test-plugin" "1.0.0" "A test plugin"

    run bash "$SCRIPT_DIR/detect-plugins.sh" --json --cache-dir "$CACHE_DIR"

    [ "$status" -eq 0 ]
    echo "$output" | jq -e '.[0].name' >/dev/null
    echo "$output" | jq -e '.[0].path' >/dev/null
}
