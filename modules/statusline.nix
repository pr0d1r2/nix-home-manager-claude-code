{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;

  statusLineSubmodule = lib.types.submodule {
    options = {
      command = lib.mkOption {
        type = lib.types.str;
        description = "Command or script path for status line.";
      };
      padding = lib.mkOption {
        type = lib.types.int;
        default = 0;
        description = "Padding characters.";
      };
      refreshInterval = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Refresh interval in seconds (min 1).";
      };
      hideVimModeIndicator = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Hide vim mode indicator.";
      };
    };
  };

  statusLineSettings = {
    inherit (cfg.statusLine) command;
  }
  // lib.optionalAttrs (cfg.statusLine.padding != 0) { inherit (cfg.statusLine) padding; }
  // lib.optionalAttrs (cfg.statusLine.refreshInterval != null) {
    inherit (cfg.statusLine) refreshInterval;
  }
  // lib.optionalAttrs cfg.statusLine.hideVimModeIndicator {
    inherit (cfg.statusLine) hideVimModeIndicator;
  };
in
{
  options.programs.claude-code.statusLine = lib.mkOption {
    type = lib.types.nullOr statusLineSubmodule;
    default = null;
    description = "Status line configuration.";
  };

  config = lib.mkIf (cfg.enable && cfg.statusLine != null) {
    programs.claude-code.settings.statusLine = statusLineSettings;
  };
}
