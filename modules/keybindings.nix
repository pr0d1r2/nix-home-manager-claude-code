{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  options.programs.claude-code.keybindings = lib.mkOption {
    type = lib.types.listOf lib.types.attrs;
    default = [ ];
    description = "Keybinding definitions for ~/.claude/keybindings.json.";
  };

  config = lib.mkIf (cfg.enable && cfg.keybindings != [ ]) {
    home.file.".claude/keybindings.json".text = builtins.toJSON cfg.keybindings;
  };
}
