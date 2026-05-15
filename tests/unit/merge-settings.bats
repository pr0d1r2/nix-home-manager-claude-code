#!/usr/bin/env bats

setup() {
  TEST_DIR="$(mktemp -d)"
  TARGET="$TEST_DIR/settings.json"
  MANAGED_KEYS="$TEST_DIR/.nix-managed-keys.json"
  export TARGET MANAGED_KEYS
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "creates settings.json when absent" {
  NIX_SETTINGS='{"model":"claude-sonnet-4-5-20250514"}' \
  ENABLED_PLUGINS='[]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"

  [ -f "$TARGET" ]
  result="$(jq -r '.model' "$TARGET")"
  [ "$result" = "claude-sonnet-4-5-20250514" ]
}

@test "deep merges into existing settings" {
  echo '{"model":"claude-sonnet-4-5-20250514","custom":"keep"}' > "$TARGET"

  NIX_SETTINGS='{"model":"claude-opus-4-20250514"}' \
  ENABLED_PLUGINS='[]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"

  result_model="$(jq -r '.model' "$TARGET")"
  result_custom="$(jq -r '.custom' "$TARGET")"
  [ "$result_model" = "claude-opus-4-20250514" ]
  [ "$result_custom" = "keep" ]
}

@test "replaces enabledPlugins entirely" {
  echo '{"enabledPlugins":["old@market"]}' > "$TARGET"

  NIX_SETTINGS='{}' \
  ENABLED_PLUGINS='["new@market"]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"

  result="$(jq -c '.enabledPlugins' "$TARGET")"
  [ "$result" = '["new@market"]' ]
}

@test "preserves user keys not managed by nix" {
  echo '{"userKey":"value","nixKey":"old"}' > "$TARGET"
  echo '["nixKey"]' > "$MANAGED_KEYS"

  NIX_SETTINGS='{"nixKey":"new"}' \
  ENABLED_PLUGINS='[]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"

  result_user="$(jq -r '.userKey' "$TARGET")"
  result_nix="$(jq -r '.nixKey' "$TARGET")"
  [ "$result_user" = "value" ]
  [ "$result_nix" = "new" ]
}

@test "removes stale managed keys" {
  echo '{"staleKey":"gone","keepKey":"stay"}' > "$TARGET"
  echo '["staleKey","keepKey"]' > "$MANAGED_KEYS"

  NIX_SETTINGS='{"keepKey":"updated"}' \
  ENABLED_PLUGINS='[]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"

  [ "$(jq 'has("staleKey")' "$TARGET")" = "false" ]
  [ "$(jq -r '.keepKey' "$TARGET")" = "updated" ]
}

@test "idempotent on repeated runs" {
  NIX_SETTINGS='{"model":"claude-opus-4-20250514"}' \
  ENABLED_PLUGINS='["p@m"]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"
  first="$(cat "$TARGET")"

  NIX_SETTINGS='{"model":"claude-opus-4-20250514"}' \
  ENABLED_PLUGINS='["p@m"]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"
  second="$(cat "$TARGET")"

  [ "$first" = "$second" ]
}

@test "atomic write via tmp file" {
  NIX_SETTINGS='{"key":"val"}' \
  ENABLED_PLUGINS='[]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"

  [ -f "$TARGET" ]
  [ ! -f "${TARGET}.tmp" ]
}

@test "tracks managed keys" {
  NIX_SETTINGS='{"a":"1","b":"2"}' \
  ENABLED_PLUGINS='[]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"

  [ -f "$MANAGED_KEYS" ]
  result="$(jq -c 'sort' "$MANAGED_KEYS")"
  [ "$result" = '["a","b"]' ]
}

@test "null typed options omit key" {
  NIX_SETTINGS='{}' \
  ENABLED_PLUGINS='[]' \
    bash lib/merge-settings.sh "$TARGET" "$MANAGED_KEYS"

  [ "$(jq 'has("model")' "$TARGET")" = "false" ]
}
