{
  pkgs,
  home-manager,
}:
# Proves/disproves the "hybrid" idea: run OUR module on top of home-manager's
# built-in programs/claude-code.nix instead of disabling it.
#
# Viability rests on four facts, each locked as an assertion below:
#   1. Upstream's settings.json is guarded -- with settings/marketplaces empty
#      it writes NO ~/.claude/settings.json, so our mutable activation-merge
#      owns that path uncontested.
#   2. Upstream writes no ~/.claude/.mcp.json (it lives in a plugin dir), so
#      our mcp merge path is uncontested too.
#   3. Our-only options (no upstream twin) coexist atop upstream cleanly.
#   4. Our declarations that SHARE a name with upstream collide on type-merge
#      today (this is why disabledModules is currently required, and the exact
#      set that a hybrid refactor must delete or rename off programs.claude-code).
let
  inherit (pkgs) lib;

  homeBase = {
    home = {
      username = "testuser";
      homeDirectory = "/home/testuser"; # nolocalpath
      stateVersion = "25.11";
    };
  };

  # Upstream module is auto-loaded by home-manager; NO disabledModules here.
  evalWith =
    extraModules:
    (home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ homeBase ] ++ extraModules;
    }).config;

  # Force option-merge + home.file config shallowly. Avoids deep-forcing
  # upstream's default file derivations (which throw for unrelated reasons).
  mergeOk =
    modulePath: leaf: value:
    let
      cfg = evalWith [
        modulePath
        {
          programs.claude-code = {
            enable = true;
          }
          // value;
        }
      ];
      r = builtins.tryEval (
        builtins.seq cfg.programs.claude-code.${leaf} (builtins.length (builtins.attrNames cfg.home.file))
      );
    in
    r.success;

  matchKeys =
    modules: suf:
    let
      cfg = evalWith modules;
    in
    builtins.filter (n: lib.hasSuffix suf n) (builtins.attrNames cfg.home.file);

  # ---- fact 1 + 4b: upstream settings.json guard ----
  settingsEmptyKeys = matchKeys [ { programs.claude-code.enable = true; } ] "settings.json";
  settingsPopulatedKeys = matchKeys [
    {
      programs.claude-code = {
        enable = true;
        settings.theme = "dark";
      };
    }
  ] "settings.json";

  # ---- fact 2: upstream writes no ~/.claude/.mcp.json ----
  mcpKeys = matchKeys [
    {
      programs.claude-code = {
        enable = true;
        mcpServers.test = {
          type = "stdio";
          command = "x";
        };
      };
    }
  ] "/.claude/.mcp.json";

  # ---- fact 3: our-only options coexist atop upstream ----
  ourOnly = {
    keybindings = mergeOk ../modules/keybindings.nix "keybindings" {
      keybindings = [
        {
          key = "ctrl+k";
          command = "t";
        }
      ];
    };
    claudeMd = mergeOk ../modules/claudemd.nix "claudeMd" {
      claudeMd.fragments = [
        {
          content = "#";
          order = 0;
        }
      ];
    };
  };

  # ---- fact 4: overlapping declarations collide on type-merge ----
  overlapCollides = {
    settings = mergeOk ../modules/settings.nix "settings" { settings.theme = "dark"; };
    hooks = mergeOk ../modules/hooks.nix "hooks" {
      hooks.PreToolUse = [
        {
          hooks = [
            {
              type = "command";
              command = "x";
            }
          ];
        }
      ];
    };
    mcpServers = mergeOk ../modules/mcp.nix "mcpServers" {
      mcpServers.test = {
        type = "stdio";
        command = "x";
      };
    };
    commands = mergeOk ../modules/commands.nix "commands" { commands.c.content = "x"; };
    plugins = mergeOk ../modules/plugins.nix "plugins" {
      plugins.p = {
        src = pkgs.emptyDirectory;
        subPlugins = [ "a" ];
      };
    };
  };

  eq =
    label: got: want:
    if got == want then
      true
    else
      builtins.throw "${label}: got ${builtins.toJSON got}, want ${builtins.toJSON want}";

  isTrue = label: got: eq label got true;
  isFalse = label: got: eq label got false;

  checks = [
    # fact 1: starved upstream emits no settings.json -> path free for our merge
    (eq "guard.settingsEmpty-no-file" settingsEmptyKeys [ ])
    # populating upstream settings DOES create the symlink at OUR exact path ->
    # proves we must never route into upstream settings
    (eq "guard.settingsPopulated-same-path" settingsPopulatedKeys [ ".claude/settings.json" ])
    # fact 2: our .mcp.json path is uncontested
    (eq "mcp.no-upstream-mcp-json" mcpKeys [ ])
    # fact 3: our-only options coexist
    (isTrue "ourOnly.keybindings" ourOnly.keybindings)
    (isTrue "ourOnly.claudeMd" ourOnly.claudeMd)
    # fact 4: overlapping declarations collide (documents refactor worklist)
    (isFalse "overlap.settings-collides" overlapCollides.settings)
    (isFalse "overlap.hooks-collides" overlapCollides.hooks)
    (isFalse "overlap.mcpServers-collides" overlapCollides.mcpServers)
    (isFalse "overlap.commands-collides" overlapCollides.commands)
    (isFalse "overlap.plugins-collides" overlapCollides.plugins)
  ];

  allPass = builtins.all (x: x) checks;
in
assert allPass;
pkgs.runCommand "hybrid-tests" { } "touch $out"
