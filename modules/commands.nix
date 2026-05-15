{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;

  commandSubmodule = lib.types.submodule {
    options = {
      content = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Inline command content.";
      };
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to command file or directory.";
      };
      recursive = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Copy source directory recursively.";
      };
    };
  };

  mkCommandFile =
    name: cmd:
    if cmd.recursive then
      {
        name = ".claude/commands/${name}";
        value = {
          inherit (cmd) source recursive;
        };
      }
    else if cmd.content != null then
      {
        name = ".claude/commands/${name}.md";
        value = {
          text = cmd.content;
        };
      }
    else
      {
        name = ".claude/commands/${name}.md";
        value = {
          inherit (cmd) source;
        };
      };
in
{
  options.programs.claude-code.commands = lib.mkOption {
    type = lib.types.attrsOf commandSubmodule;
    default = { };
    description = "Command definitions placed at ~/.claude/commands/.";
  };

  config = lib.mkIf (cfg.enable && cfg.commands != { }) {
    home.file = lib.listToAttrs (lib.mapAttrsToList mkCommandFile cfg.commands);
  };
}
