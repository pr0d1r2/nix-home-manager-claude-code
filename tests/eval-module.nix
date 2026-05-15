{
  pkgs,
  home-manager,
}:
let
  evalModule =
    config:
    (home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        {
          disabledModules = [ "programs/claude-code.nix" ];
        }
        ../modules/default.nix
        {
          home = {
            username = "testuser";
            homeDirectory = "/home/testuser"; # nolocalpath
            stateVersion = "25.11";
          };
        }
        config
      ];
    }).config;

  enableOnly = evalModule { programs.claude-code.enable = true; };

  withHookScript = evalModule {
    programs.claude-code = {
      enable = true;
      hookScripts."test-hook.sh".text = "echo hello";
    };
  };

  withHookScriptRuntime = evalModule {
    programs.claude-code = {
      enable = true;
      hookScripts."runtime-hook.sh" = {
        text = "echo hello";
        runtimeInputs = [ pkgs.jq ];
      };
    };
  };

  withCommand = evalModule {
    programs.claude-code = {
      enable = true;
      commands."test-cmd".content = "Test command content";
    };
  };

  withRule = evalModule {
    programs.claude-code = {
      enable = true;
      rules."test-rule".content = "Test rule content";
    };
  };

  withKeybindings = evalModule {
    programs.claude-code = {
      enable = true;
      keybindings = [
        {
          key = "ctrl+k";
          command = "test";
        }
      ];
    };
  };

  withClaudemd = evalModule {
    programs.claude-code = {
      enable = true;
      claudeMd.fragments = [
        {
          content = "# Test";
          order = 0;
        }
      ];
    };
  };

  withSettings = evalModule {
    programs.claude-code = {
      enable = true;
      settings.theme = "dark";
    };
  };

  withMcp = evalModule {
    programs.claude-code = {
      enable = true;
      mcpServers.test-server = {
        type = "stdio";
        command = "test-cmd";
      };
    };
  };

  withPlugin = evalModule {
    programs.claude-code = {
      enable = true;
      plugins.test-plugin = {
        src = pkgs.emptyDirectory;
        subPlugins = [
          "sub-a"
          "sub-b"
        ];
      };
    };
  };

  withCleanPluginData = evalModule {
    programs.claude-code = {
      enable = true;
      plugins.test-plugin = {
        src = pkgs.emptyDirectory;
        subPlugins = [ "sub-a" ];
      };
      cleanPluginData = true;
    };
  };

  withBlockedPlugins = evalModule {
    programs.claude-code = {
      enable = true;
      plugins.test-plugin = {
        src = pkgs.emptyDirectory;
        subPlugins = [ "sub-a" ];
      };
      blockedPlugins = [ "bad@market" ];
    };
  };

  withCredentials = evalModule {
    programs.claude-code = {
      enable = true;
      credentials.source = pkgs.writeText "test-creds" "{}";
    };
  };

  withoutCredentials = evalModule {
    programs.claude-code = {
      enable = true;
    };
  };

  hasHomeFile = cfg: name: builtins.hasAttr name cfg.home.file;

  assertHomeFile =
    label: cfg: name:
    if hasHomeFile cfg name then
      true
    else
      builtins.throw "${label}: expected home.file.\"${name}\" to exist";

  assertNoHomeFile =
    label: cfg: name:
    if !(hasHomeFile cfg name) then
      true
    else
      builtins.throw "${label}: expected home.file.\"${name}\" to NOT exist";

  hasActivation = cfg: name: builtins.hasAttr name cfg.home.activation;

  assertActivation =
    label: cfg: name:
    if hasActivation cfg name then
      true
    else
      builtins.throw "${label}: expected home.activation.\"${name}\" to exist";

  assertSettingsKey =
    label: cfg: key:
    let
      inherit (cfg.programs.claude-code) settings;
    in
    if builtins.hasAttr key settings then
      true
    else
      builtins.throw "${label}: expected settings.\"${key}\" to exist";

  assertEnabledPlugins =
    label: cfg: expected:
    let
      actual = cfg.programs.claude-code._internal.enabledPlugins;
    in
    if actual == expected then
      true
    else
      builtins.throw "${label}: enabledPlugins mismatch: got ${builtins.toJSON actual}";

  checks = [
    (assertHomeFile "hook-script" withHookScript ".claude/hooks/test-hook.sh")
    (assertHomeFile "hook-script-runtime" withHookScriptRuntime ".claude/hooks/runtime-hook.sh")
    (assertHomeFile "command" withCommand ".claude/commands/test-cmd.md")
    (assertHomeFile "rule" withRule ".claude/rules/test-rule.md")
    (assertHomeFile "keybindings" withKeybindings ".claude/keybindings.json")
    (assertHomeFile "claudemd" withClaudemd ".claude/CLAUDE.md")
    (assertActivation "settings-merge" withSettings "claudeSettings")
    (assertActivation "mcp-merge" withMcp "claudeMcp")
    (assertActivation "settings-always" enableOnly "claudeSettings")
    (assertNoHomeFile "no-package" enableOnly ".claude/hooks/test-hook.sh")
    (assertHomeFile "plugin-files" withPlugin ".claude/nix-plugins/test-plugin")
    (assertSettingsKey "extraKnownMarketplaces" withPlugin "extraKnownMarketplaces")
    (assertEnabledPlugins "enabledPlugins" withPlugin [
      "sub-a@test-plugin"
      "sub-b@test-plugin"
    ])
    (assertActivation "clean-plugin-cache" withPlugin "claudeCleanPluginCache")
    (assertActivation "blocklist-merge" withBlockedPlugins "claudeBlocklist")
    (assertActivation "clean-plugin-data" withCleanPluginData "claudeCleanPluginData")
    (assertHomeFile "credentials" withCredentials ".claude/.credentials.json")
    (assertNoHomeFile "no-credentials" withoutCredentials ".claude/.credentials.json")
  ];

  allPass = builtins.all (x: x) checks;
in
assert allPass;
pkgs.runCommand "eval-module-tests" { } "touch $out"
