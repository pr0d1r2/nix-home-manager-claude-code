#!/usr/bin/env bats

setup() {
    export TEST_DIR
    TEST_DIR="$(mktemp -d)"
    export CLAUDE_DIR="$TEST_DIR/.claude"
    mkdir -p "$CLAUDE_DIR/hooks" "$CLAUDE_DIR/commands"
    export REPO_DIR="$TEST_DIR/repo"
    mkdir -p "$REPO_DIR/files/hooks" "$REPO_DIR/files/commands"
    export SCRIPT_DIR
    SCRIPT_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")/../../scripts" && pwd)"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "dry-run lists hooks that would be backed up" {
    touch "$REPO_DIR/files/hooks/statusline.sh"
    touch "$REPO_DIR/files/hooks/caveman-activate.sh"
    touch "$CLAUDE_DIR/hooks/statusline.sh"
    touch "$CLAUDE_DIR/hooks/caveman-activate.sh"

    run bash "$SCRIPT_DIR/migrate.sh" --dry-run --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -eq 0 ]
    [[ "$output" == *"hooks/statusline.sh"* ]]
    [[ "$output" == *"hooks/caveman-activate.sh"* ]]
}

@test "dry-run does not modify filesystem" {
    touch "$REPO_DIR/files/hooks/statusline.sh"
    touch "$CLAUDE_DIR/hooks/statusline.sh"

    bash "$SCRIPT_DIR/migrate.sh" --dry-run --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ -f "$CLAUDE_DIR/hooks/statusline.sh" ]
    [ ! -f "$CLAUDE_DIR/hooks/statusline.sh.backup" ]
}

@test "backup renames hooks to .backup" {
    touch "$REPO_DIR/files/hooks/statusline.sh"
    touch "$CLAUDE_DIR/hooks/statusline.sh"

    run bash "$SCRIPT_DIR/migrate.sh" --backup --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -eq 0 ]
    [ ! -f "$CLAUDE_DIR/hooks/statusline.sh" ]
    [ -f "$CLAUDE_DIR/hooks/statusline.sh.backup" ]
}

@test "backup renames commands to .backup" {
    touch "$REPO_DIR/files/commands/cover-rb.md"
    touch "$CLAUDE_DIR/commands/cover-rb.md"

    run bash "$SCRIPT_DIR/migrate.sh" --backup --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -eq 0 ]
    [ ! -f "$CLAUDE_DIR/commands/cover-rb.md" ]
    [ -f "$CLAUDE_DIR/commands/cover-rb.md.backup" ]
}

@test "backup skips already backed up files (idempotent)" {
    touch "$REPO_DIR/files/hooks/statusline.sh"
    touch "$CLAUDE_DIR/hooks/statusline.sh.backup"

    run bash "$SCRIPT_DIR/migrate.sh" --backup --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -eq 0 ]
    [[ "$output" == *"skip"* ]]
    [ -f "$CLAUDE_DIR/hooks/statusline.sh.backup" ]
}

@test "backup skips files not present in claude dir" {
    touch "$REPO_DIR/files/hooks/statusline.sh"

    run bash "$SCRIPT_DIR/migrate.sh" --backup --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -eq 0 ]
    [ ! -f "$CLAUDE_DIR/hooks/statusline.sh.backup" ]
}

@test "nix-config prints home.file attr paths for hooks" {
    touch "$REPO_DIR/files/hooks/statusline.sh"
    touch "$REPO_DIR/files/hooks/caveman-activate.sh"

    run bash "$SCRIPT_DIR/migrate.sh" --nix-config --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -eq 0 ]
    [[ "$output" == *'home.file.".claude/hooks/statusline.sh"'* ]]
    [[ "$output" == *'home.file.".claude/hooks/caveman-activate.sh"'* ]]
}

@test "nix-config prints home.file attr paths for commands" {
    touch "$REPO_DIR/files/commands/cover-rb.md"

    run bash "$SCRIPT_DIR/migrate.sh" --nix-config --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -eq 0 ]
    [[ "$output" == *'home.file.".claude/commands/cover-rb.md"'* ]]
}

@test "names derived from repo files/ not hardcoded" {
    touch "$REPO_DIR/files/hooks/custom-new-hook.sh"
    touch "$CLAUDE_DIR/hooks/custom-new-hook.sh"

    run bash "$SCRIPT_DIR/migrate.sh" --dry-run --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -eq 0 ]
    [[ "$output" == *"hooks/custom-new-hook.sh"* ]]
}

@test "does not touch settings.json or mcp.json or plugins" {
    touch "$CLAUDE_DIR/settings.json"
    touch "$CLAUDE_DIR/.mcp.json"
    mkdir -p "$CLAUDE_DIR/plugins"
    touch "$CLAUDE_DIR/plugins/some-plugin"
    touch "$REPO_DIR/files/hooks/statusline.sh"

    bash "$SCRIPT_DIR/migrate.sh" --backup --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ -f "$CLAUDE_DIR/settings.json" ]
    [ -f "$CLAUDE_DIR/.mcp.json" ]
    [ -f "$CLAUDE_DIR/plugins/some-plugin" ]
}

@test "no mode flag prints usage" {
    run bash "$SCRIPT_DIR/migrate.sh" --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -ne 0 ]
    [[ "$output" == *"Usage"* ]]
}

@test "handles subdirectory commands" {
    mkdir -p "$REPO_DIR/files/commands/humor"
    touch "$REPO_DIR/files/commands/humor/sarcasm.md"
    mkdir -p "$CLAUDE_DIR/commands/humor"
    touch "$CLAUDE_DIR/commands/humor/sarcasm.md"

    run bash "$SCRIPT_DIR/migrate.sh" --backup --claude-dir "$CLAUDE_DIR" --repo-dir "$REPO_DIR"

    [ "$status" -eq 0 ]
    [ ! -f "$CLAUDE_DIR/commands/humor/sarcasm.md" ]
    [ -f "$CLAUDE_DIR/commands/humor/sarcasm.md.backup" ]
}
