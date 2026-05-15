{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  imports = [
    ./plugins.nix
    ./settings.nix
    ./spinner.nix
    ./mcp.nix
    ./hooks.nix
    ./statusline.nix
    ./hook-scripts.nix
    ./permissions.nix
    ./commands.nix
    ./claudemd.nix
    ./rules.nix
    ./keybindings.nix
    ./credentials.nix
    ./presets/caveman.nix
    ./presets/doomer.nix
    ./presets/skeptic.nix
    ./presets/security.nix
    ./defaults.nix
  ];

  options.programs.claude-code = {
    enable = lib.mkEnableOption "Claude Code";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = null;
      description = "Claude Code package to install. When null, assumes claude is installed externally.";
    };

    presets = {
      all = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable all presets except spinner (doomer/skeptic).";
      };
      caveman = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install caveman hooks (UserPromptSubmit + SessionStart).";
      };
      doomer = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set doomer spinnerVerbs (replace mode).";
      };
      skeptic = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Set skeptic spinnerVerbs (replace mode).";
      };
      security = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Add deny rules for destructive ops.";
      };
      autoCommit = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install auto-commit hooks (~/.claude + project).";
      };
      coverage = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install coverage-check hook (post-commit coverage checkers).";
      };
      justfile = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install justfile-extract hook.";
      };
      sessionId = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install session-id hook (injects session ID on start).";
      };
      statusline = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install statusline aggregator hook.";
      };
      gh = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install GitHub CLI statusline hook.";
      };
      gitStatus = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install git status statusline hook.";
      };
      rtk = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install RTK hook scripts (rewrite + statusline).";
      };
      semble = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install Semble statusline hook.";
      };
      astfold = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Install AST fold statusline hook.";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = lib.optional (cfg.package != null) cfg.package;
      }

      (lib.mkIf cfg.presets.all {
        programs.claude-code.presets = {
          caveman = lib.mkDefault true;
          security = lib.mkDefault true;
          autoCommit = lib.mkDefault true;
          coverage = lib.mkDefault true;
          justfile = lib.mkDefault true;
          sessionId = lib.mkDefault true;
          statusline = lib.mkDefault true;
          gh = lib.mkDefault true;
          gitStatus = lib.mkDefault true;
          rtk = lib.mkDefault true;
          semble = lib.mkDefault true;
          astfold = lib.mkDefault true;
        };
      })
    ]
  );
}
