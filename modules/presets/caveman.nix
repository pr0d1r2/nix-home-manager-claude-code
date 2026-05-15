{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  config = lib.mkIf (cfg.enable && cfg.presets.caveman) {
    programs.claude-code.hooks = {
      UserPromptSubmit = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = "bash";
              args = [
                "$HOME/.claude/hooks/caveman-activate.sh"
              ];
              timeout = 5000;
            }
          ];
        }
      ];
      SessionStart = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = "bash";
              args = [
                "$HOME/.claude/hooks/caveman-mode-tracker.sh"
              ];
              timeout = 5000;
            }
          ];
        }
      ];
    };
  };
}
