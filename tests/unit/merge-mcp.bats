#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    TARGET="$TEST_DIR/.mcp.json"
    MANAGED_KEYS="$TEST_DIR/.nix-managed-mcp-keys.json"
    export TARGET MANAGED_KEYS
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "creates .mcp.json when absent" {
    NIX_MCP='{"mcpServers":{"semble":{"type":"stdio","command":"semble"}}}' \
        bash lib/merge-mcp.sh "$TARGET" "$MANAGED_KEYS"

    [ -f "$TARGET" ]
    result="$(jq -r '.mcpServers.semble.command' "$TARGET")"
    [ "$result" = "semble" ]
}

@test "merges new servers into existing" {
    echo '{"mcpServers":{"manual":{"type":"stdio","command":"manual-tool"}}}' >"$TARGET"

    NIX_MCP='{"mcpServers":{"nix-tool":{"type":"stdio","command":"nix-tool"}}}' \
        bash lib/merge-mcp.sh "$TARGET" "$MANAGED_KEYS"

    [ "$(jq -r '.mcpServers.manual.command' "$TARGET")" = "manual-tool" ]
    [ "$(jq -r '.mcpServers["nix-tool"].command' "$TARGET")" = "nix-tool" ]
}

@test "removes old managed servers no longer in config" {
    echo '{"mcpServers":{"old-nix":{"type":"stdio","command":"old"},"manual":{"type":"stdio","command":"keep"}}}' >"$TARGET"
    echo '["old-nix"]' >"$MANAGED_KEYS"

    NIX_MCP='{"mcpServers":{"new-nix":{"type":"stdio","command":"new"}}}' \
        bash lib/merge-mcp.sh "$TARGET" "$MANAGED_KEYS"

    [ "$(jq 'has("old-nix")' "$TARGET" 2>/dev/null || jq '.mcpServers | has("old-nix")' "$TARGET")" = "false" ]
    [ "$(jq -r '.mcpServers.manual.command' "$TARGET")" = "keep" ]
    [ "$(jq -r '.mcpServers["new-nix"].command' "$TARGET")" = "new" ]
}

@test "preserves manually added servers" {
    echo '{"mcpServers":{"manual":{"type":"sse","url":"http://localhost:3000"}}}' >"$TARGET"

    NIX_MCP='{"mcpServers":{"nix-srv":{"type":"stdio","command":"srv"}}}' \
        bash lib/merge-mcp.sh "$TARGET" "$MANAGED_KEYS"

    [ "$(jq -r '.mcpServers.manual.url' "$TARGET")" = "http://localhost:3000" ]
}

@test "idempotent on repeated runs" {
    NIX_MCP='{"mcpServers":{"s":{"type":"stdio","command":"s"}}}' \
        bash lib/merge-mcp.sh "$TARGET" "$MANAGED_KEYS"
    first="$(cat "$TARGET")"

    NIX_MCP='{"mcpServers":{"s":{"type":"stdio","command":"s"}}}' \
        bash lib/merge-mcp.sh "$TARGET" "$MANAGED_KEYS"
    second="$(cat "$TARGET")"

    [ "$first" = "$second" ]
}

@test "tracks managed server names" {
    NIX_MCP='{"mcpServers":{"a":{"type":"stdio","command":"a"},"b":{"type":"stdio","command":"b"}}}' \
        bash lib/merge-mcp.sh "$TARGET" "$MANAGED_KEYS"

    [ -f "$MANAGED_KEYS" ]
    result="$(jq -c 'sort' "$MANAGED_KEYS")"
    [ "$result" = '["a","b"]' ]
}

@test "atomic write via tmp file" {
    NIX_MCP='{"mcpServers":{"x":{"type":"stdio","command":"x"}}}' \
        bash lib/merge-mcp.sh "$TARGET" "$MANAGED_KEYS"

    [ -f "$TARGET" ]
    [ ! -f "${TARGET}.tmp" ]
}

@test "creates parent directory when absent" {
    TARGET="$TEST_DIR/subdir/.mcp.json"
    MANAGED_KEYS="$TEST_DIR/subdir/.nix-managed-mcp-keys.json"

    NIX_MCP='{"mcpServers":{"s":{"type":"stdio","command":"s"}}}' \
        bash lib/merge-mcp.sh "$TARGET" "$MANAGED_KEYS"

    [ -f "$TARGET" ]
    [ -f "$MANAGED_KEYS" ]
}
