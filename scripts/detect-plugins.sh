#!/usr/bin/env bash
set -euo pipefail

CACHE_DIR="${HOME}/.claude/plugins/cache"
JSON_MODE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
  --json)
    JSON_MODE=true
    shift
    ;;
  --cache-dir)
    CACHE_DIR="$2"
    shift 2
    ;;
  *)
    echo "Usage: detect-plugins.sh [--json] [--cache-dir DIR]"
    exit 1
    ;;
  esac
done

if [[ ! -d "$CACHE_DIR" ]]; then
  if [[ "$JSON_MODE" == "true" ]]; then
    echo "[]"
  fi
  exit 0
fi

PLUGINS_JSON="[]"

while IFS= read -r plugin_json; do
  [[ -z "$plugin_json" ]] && continue
  plugin_dir="$(dirname "$plugin_json")"
  plugin_root="$(dirname "$plugin_dir")"
  name="$(jq -r '.name // "unknown"' "$plugin_json")"
  version="$(jq -r '.version // "unknown"' "$plugin_json")"
  desc="$(jq -r '.description // ""' "$plugin_json")"

  if [[ "$JSON_MODE" == "true" ]]; then
    entry="$(jq -n \
      --arg name "$name" \
      --arg version "$version" \
      --arg desc "$desc" \
      --arg path "$plugin_root" \
      '{name: $name, version: $version, description: $desc, path: $path}')"
    PLUGINS_JSON="$(echo "$PLUGINS_JSON" | jq --argjson e "$entry" '. + [$e]')"
  else
    echo "# $name ($version) - $desc"
    echo "\"$name\" = {"
    echo "  src = builtins.fetchGit {"
    echo "    url = \"$plugin_root\";"
    echo "  };"
    echo "};"
    echo ""
  fi
done < <(find "$CACHE_DIR" -path '*/.claude-plugin/plugin.json' -type f 2>/dev/null | sort)

if [[ "$JSON_MODE" == "true" ]]; then
  echo "$PLUGINS_JSON"
fi
