{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.claude-code;

  typedSettings = lib.filterAttrs (_: v: v != null) {
    inherit (cfg)
      model
      thinkingBudget
      promptSuggestions
      buddyMode
      ;
    env = if cfg.env == { } then null else cfg.env;
  };

  mergedSettings = typedSettings // cfg.settings;

  mergeScript = pkgs.replaceVars ../lib/run-merge-settings.sh {
    jq = "${pkgs.jq}/bin";
    coreutils = "${pkgs.coreutils}/bin";
    nixSettings = builtins.toJSON mergedSettings;
    enabledPlugins = builtins.toJSON cfg._internal.enabledPlugins;
    mergeScript = ../lib/merge-settings.sh;
  };
in
{
  options.programs.claude-code = {
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "Freeform settings merged into settings.json. Overrides typed options.";
    };

    model = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Claude model to use.";
    };

    thinkingBudget = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "none"
          "low"
          "medium"
          "high"
          "max"
        ]
      );
      default = null;
      description = "Thinking budget level.";
    };

    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables for Claude Code.";
    };

    promptSuggestions = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = "Enable prompt suggestions.";
    };

    buddyMode = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = "Enable buddy mode.";
    };

    _internal.enabledPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      internal = true;
      description = "Enabled plugin IDs computed by plugins module.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.claudeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD bash ${mergeScript}
    '';
  };
}
