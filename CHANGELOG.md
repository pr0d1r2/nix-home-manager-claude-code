# Changelog

## 0.1.0 — Initial Release

### Module

- Declarative home-manager module for Claude Code (`programs.claude-code`)
- Core options: `enable`, `package`, `model`, `thinkingBudget`
- Freeform `settings` merged into `~/.claude/settings.json` (deep merge, preserves manual edits)
- MCP server definitions merged into `~/.claude/.mcp.json`
- Hook scripts with `text`, `source`, `vars`, and `runtimeInputs` modes
- Custom commands placed at `~/.claude/commands/`
- Custom rules placed at `~/.claude/rules/`
- Keybindings as `~/.claude/keybindings.json`
- CLAUDE.md composition from ordered fragments
- Permissions with allow/deny lists and `defaultMode`
- Spinner verb customization (replace or append)
- Status line configuration
- Environment variables via `env`

### Plugins

- Plugin marketplace definitions with `src`, `marketplace`, and `subPlugins`
- Automatic `extraKnownMarketplaces` registration in settings
- Automatic `enabledPlugins` computation from sub-plugin lists
- `blockedPlugins` list merged into `~/.claude/blocklist.json`
- `cleanPluginData` option to remove stale plugin data dirs on rebuild
- Stale `~/.claude/nix-plugins/` cache cleanup on rebuild

### Presets

- `security` — deny rules for destructive operations
- `caveman` — caveman mode hooks (SessionStart + UserPromptSubmit)
- `doomer` — doomer spinner verbs
- `skeptic` — skeptic spinner verbs (mutually exclusive with doomer)

### Merge Behavior

- Settings and MCP servers are deep-merged, preserving manual edits
- Managed keys tracked in `.nix-managed-keys.json` / `.nix-managed-mcp-keys.json`
- Stale managed keys automatically removed on rebuild
- Blocklist entries merged with old-entry cleanup

### Tooling

- Migration script (`scripts/migrate.sh`) with `--dry-run`, `--backup`, `--nix-config`
- Plugin detection script (`scripts/detect-plugins.sh`) with Nix snippet and JSON output
- Flake templates for plugin and marketplace scaffolding
- Built-in hook scripts for coverage checking (README drift, Ruby specs, shell bats)

### Testing

- 77 bats tests covering all shell scripts
- 17 Nix eval-module assertions
- Integration test building full home-manager generation
- CI via GitHub Actions (Linux + macOS)

### Development

- Nix flake with dev shell, lefthook, and 18 pre-commit checks
- Portable to macOS and Linux (aarch64 + x86_64)
