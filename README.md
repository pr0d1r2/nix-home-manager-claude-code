# nix-home-manager-claude-code

[![CI](https://github.com/pr0d1r2/nix-home-manager-claude-code/actions/workflows/ci.yml/badge.svg)](https://github.com/pr0d1r2/nix-home-manager-claude-code/actions/workflows/ci.yml)

Declarative home-manager module for Claude Code configuration. Manages settings, MCP servers, hooks, commands, rules, keybindings, CLAUDE.md, permissions, and plugins — all merge-safe with mutable `~/.claude/` files.

## Quick Start

Add to your flake inputs:

```nix
{
  inputs.nix-home-manager-claude-code = {
    url = "github:pr0d1r2/nix-home-manager-claude-code";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Import the module and enable:

```nix
{
  imports = [ nix-home-manager-claude-code.homeManagerModules.default ];

  programs.claude-code = {
    enable = true;
    model = "claude-sonnet-4-6";
    settings.theme = "dark";
  };
}
```

**Note:** You must disable home-manager's built-in claude-code module to avoid conflicts:

```nix
{
  disabledModules = [ "programs/claude-code.nix" ];
}
```

## Options

### Core

| Option | Type | Default | Description |
| ------ | ---- | ------- | ----------- |
| `enable` | bool | `false` | Enable Claude Code module |
| `package` | package or null | `null` | Claude Code package (null = installed externally) |
| `model` | string or null | `null` | Claude model to use |
| `thinkingBudget` | enum or null | `null` | Thinking budget: none/low/medium/high/max |
| `settings` | attrs | `{}` | Freeform settings merged into settings.json |
| `env` | attrs | `{}` | Environment variables |
| `credentials.source` | path or null | `null` | Path to credentials.json (symlinked to ~/.claude/.credentials.json) |

### MCP Servers

```nix
programs.claude-code.mcpServers = {
  my-server = {
    type = "stdio";
    command = "my-mcp-server";
    args = [ "--port" "3000" ];
    env.API_KEY = "...";
  };
  my-http-server = {
    type = "streamable-http";
    url = "http://localhost:8080/mcp";
  };
};
```

### Hooks

```nix
programs.claude-code.hooks = {
  UserPromptSubmit = [
    {
      hooks = [
        {
          type = "command";
          command = "echo 'prompt submitted'";
          timeout = 5;
        }
      ];
    }
  ];
};
```

### Hook Scripts

Scripts placed at `~/.claude/hooks/`:

```nix
programs.claude-code.hookScripts = {
  "my-hook.sh".text = ''
    #!/usr/bin/env bash
    echo "hook ran"
  '';
  "other-hook.sh".source = ./hooks/other.sh;
  "with-deps.sh" = {
    text = ''
      echo '{}' | jq '.foo = "bar"'
    '';
    runtimeInputs = [ pkgs.jq ];
  };
};
```

When `runtimeInputs` is set, the script is wrapped with `writeShellApplication` so listed packages are on `PATH`.

### Commands

```nix
programs.claude-code.commands = {
  "my-command".content = "Do the thing described here.";
  "from-file".source = ./commands/my-command.md;
  "humor" = {
    source = ./commands/humor;
    recursive = true;
  };
};
```

### Rules

```nix
programs.claude-code.rules = {
  "no-console".content = "Never use console.log in production code.";
  "style-guide".source = ./rules/style.md;
};
```

### CLAUDE.md Composition

```nix
programs.claude-code.claudeMd.fragments = [
  { content = "# Project Rules"; order = 0; }
  { content = "Always use TypeScript."; order = 10; }
  { source = ./claude-fragments/testing.md; order = 20; }
];
```

### Permissions

```nix
programs.claude-code.permissions = {
  allow = [ "Bash(npm test)" "Bash(npm run build)" ];
  deny = [ "Bash(rm -rf *)" "Bash(git push --force *)" ];
};
programs.claude-code.defaultMode = "auto";
```

### Keybindings

```nix
programs.claude-code.keybindings = [
  { key = "ctrl+k"; command = "clear"; }
];
```

### Spinner Verbs

```nix
programs.claude-code.spinnerVerbs = {
  mode = "replace";
  verbs = [ "Thinking hard" "Computing" "Reasoning" ];
};
```

### Status Line

```nix
programs.claude-code.statusLine = {
  command = "echo 'status'";
  refreshInterval = 5;
};
```

### Plugins

Install plugin marketplaces from Nix sources:

```nix
programs.claude-code.plugins = {
  my-marketplace = {
    src = inputs.my-marketplace;
    subPlugins = [ "plugin-a" "plugin-b" ];
  };
};
```

Each marketplace is symlinked to `~/.claude/nix-plugins/<name>` and registered in `extraKnownMarketplaces`. Sub-plugins are added to `enabledPlugins` automatically.

Block specific plugins:

```nix
programs.claude-code.blockedPlugins = [ "bad-plugin@some-marketplace" ];
```

Remove data dirs for plugins no longer in config on rebuild:

```nix
programs.claude-code.cleanPluginData = true;
```

## Presets

Enable built-in presets for common configurations:

```nix
programs.claude-code.presets = {
  security = true;   # Deny rules for destructive operations
  caveman = true;    # Caveman mode hooks (SessionStart + UserPromptSubmit)
  doomer = true;     # Doomer spinner verbs (mutually exclusive with skeptic)
  skeptic = true;    # Skeptic spinner verbs (mutually exclusive with doomer)
};
```

## Migration

Migrate from manually managed `~/.claude/` to Nix-managed:

```bash
# See what would be backed up
bash scripts/migrate.sh --dry-run

# Back up existing files (renames to .backup, never deletes)
bash scripts/migrate.sh --backup

# Show home.file attr paths to remove from old config
bash scripts/migrate.sh --nix-config
```

Migration is idempotent — files already backed up are skipped.

## Detecting Plugins

Scan for manually installed plugins not yet in your Nix config:

```bash
# Output Nix snippets ready to paste
bash scripts/detect-plugins.sh

# Machine-readable JSON
bash scripts/detect-plugins.sh --json
```

## Templates

Bootstrap new plugin or marketplace repos:

```bash
# Single plugin
nix flake init -t github:pr0d1r2/nix-home-manager-claude-code#plugin

# Plugin marketplace
nix flake init -t github:pr0d1r2/nix-home-manager-claude-code#marketplace
```

## NixOS Usage

This module works inside NixOS via `home-manager.users.<name>`:

```nix
{
  inputs = {
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    nix-home-manager-claude-code.url = "github:pr0d1r2/nix-home-manager-claude-code";
  };
}
```

```nix
home-manager.users.myuser = {
  imports = [
    nix-home-manager-claude-code.homeManagerModules.default
  ];

  disabledModules = [ "programs/claude-code.nix" ];

  programs.claude-code = {
    enable = true;
    model = "claude-opus-4-6";
    thinkingBudget = "medium";
    credentials.source = ./secrets/credentials.json;
    presets.security = true;
  };
};
```

## Merge Behavior

Settings, MCP servers, and blocklist are **merge-managed**: Nix-declared keys are deep-merged into existing files, preserving manual edits. Managed keys are tracked in `.nix-managed-keys.json` / `.nix-managed-mcp-keys.json` — stale keys are automatically removed on rebuild.

All other files (hooks, commands, rules, keybindings, CLAUDE.md) are **fully owned** by Nix via `home.file`.

## Development

```bash
# Enter dev shell
direnv allow

# Run tests
bats tests/

# Check everything
nix flake check
```
