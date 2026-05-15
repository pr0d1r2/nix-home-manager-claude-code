{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  options.programs.claude-code.credentials = {
    source = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to credentials.json file. Symlinked to ~/.claude/.credentials.json.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.credentials.source != null) {
    home.file.".claude/.credentials.json" = {
      inherit (cfg.credentials) source;
    };
  };
}
