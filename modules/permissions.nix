{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;

  permSettings =
    lib.optionalAttrs (cfg.permissions.allow != [ ]) {
      "permissions.allow" = cfg.permissions.allow;
    }
    // lib.optionalAttrs (cfg.permissions.ask != [ ]) {
      "permissions.ask" = cfg.permissions.ask;
    }
    // lib.optionalAttrs (cfg.permissions.deny != [ ]) {
      "permissions.deny" = cfg.permissions.deny;
    }
    // lib.optionalAttrs (cfg.defaultMode != "default") {
      inherit (cfg) defaultMode;
    }
    // lib.optionalAttrs (cfg.additionalDirectories != [ ]) {
      inherit (cfg) additionalDirectories;
    };
in
{
  options.programs.claude-code = {
    permissions = {
      allow = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Auto-approve permission patterns.";
      };
      ask = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Prompt-per-use permission patterns.";
      };
      deny = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Block permission patterns. Evaluated first, deny wins.";
      };
    };

    defaultMode = lib.mkOption {
      type = lib.types.enum [
        "default"
        "acceptEdits"
        "plan"
        "auto"
        "dontAsk"
        "bypassPermissions"
      ];
      default = "default";
      description = "Default permission mode.";
    };

    additionalDirectories = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Extra paths Claude can access.";
    };
  };

  config = lib.mkIf (cfg.enable && permSettings != { }) {
    programs.claude-code.settings = permSettings;
  };
}
