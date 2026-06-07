#!/usr/bin/env bash
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
REPO_DIR=""
MODE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
  --dry-run)
    MODE="dry-run"
    shift
    ;;
  --backup)
    MODE="backup"
    shift
    ;;
  --nix-config)
    MODE="nix-config"
    shift
    ;;
  --claude-dir)
    CLAUDE_DIR="$2"
    shift 2
    ;;
  --repo-dir)
    REPO_DIR="$2"
    shift 2
    ;;
  *)
    echo "Usage: migrate.sh {--dry-run|--backup|--nix-config} [--claude-dir DIR] [--repo-dir DIR]"
    exit 1
    ;;
  esac
done

if [[ -z "$MODE" ]]; then
  echo "Usage: migrate.sh {--dry-run|--backup|--nix-config} [--claude-dir DIR] [--repo-dir DIR]"
  exit 1
fi

if [[ -z "$REPO_DIR" ]]; then
  REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fi

NAMES=()
while IFS= read -r line; do
  [[ -n "$line" ]] && NAMES+=("$line")
done < <(bash "$(dirname "$0")/collect-managed-names.sh" "$REPO_DIR")

case "$MODE" in
dry-run)
  for name in "${NAMES[@]}"; do
    target="$CLAUDE_DIR/$name"
    if [[ -f "$target" ]]; then
      echo "would backup: $name"
    fi
  done
  ;;
backup)
  for name in "${NAMES[@]}"; do
    target="$CLAUDE_DIR/$name"
    if [[ -f "${target}.backup" ]]; then
      echo "skip: ${name}.backup already exists"
      continue
    fi
    if [[ -f "$target" ]]; then
      mv "$target" "${target}.backup"
      echo "backed up: $name"
    fi
  done
  ;;
nix-config)
  for name in "${NAMES[@]}"; do
    echo "home.file.\".claude/${name}\""
  done
  ;;
esac
