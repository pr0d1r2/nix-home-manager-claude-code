{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;

  spinnerSubmodule = lib.types.submodule {
    options = {
      mode = lib.mkOption {
        type = lib.types.enum [
          "replace"
          "append"
        ];
        description = "Whether to replace or append to default spinner verbs.";
      };
      verbs = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "List of spinner verb strings.";
      };
    };
  };
in
{
  options.programs.claude-code.spinnerVerbs = lib.mkOption {
    type = lib.types.nullOr spinnerSubmodule;
    default = null;
    description = "Custom spinner verbs configuration.";
  };

  config = lib.mkIf (cfg.enable && cfg.spinnerVerbs != null) {
    programs.claude-code.settings.spinnerVerbs = cfg.spinnerVerbs;
  };
}
