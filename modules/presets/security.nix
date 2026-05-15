{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;
in
{
  config = lib.mkIf (cfg.enable && cfg.presets.security) {
    programs.claude-code.permissions.deny = [
      "Bash(rm -rf *)"
      "Bash(git push --force *)"
      "Bash(git reset --hard *)"
      "Bash(git clean -f*)"
    ];
  };
}
