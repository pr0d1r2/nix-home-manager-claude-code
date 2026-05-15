{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.claude-code;

  hookScriptSubmodule = lib.types.submodule {
    options = {
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to script source file.";
      };
      text = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Inline script content.";
      };
      vars = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Variables for replaceVars substitution.";
      };
      runtimeInputs = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Packages added to PATH via writeShellApplication.";
      };
    };
  };

  mkHookScript =
    name: script:
    if script.text != null && script.runtimeInputs != [ ] then
      let
        app = pkgs.writeShellApplication {
          inherit name;
          inherit (script) runtimeInputs text;
        };
      in
      {
        name = ".claude/hooks/${name}";
        value = {
          source = "${app}/bin/${name}";
          executable = true;
        };
      }
    else if script.text != null then
      {
        name = ".claude/hooks/${name}";
        value = {
          source = pkgs.writeScript name script.text;
          executable = true;
        };
      }
    else if script.vars != { } then
      {
        name = ".claude/hooks/${name}";
        value = {
          source = pkgs.replaceVars script.source script.vars;
          executable = true;
        };
      }
    else
      {
        name = ".claude/hooks/${name}";
        value = {
          inherit (script) source;
          executable = true;
        };
      };
in
{
  options.programs.claude-code.hookScripts = lib.mkOption {
    type = lib.types.attrsOf hookScriptSubmodule;
    default = { };
    description = "Hook scripts placed at ~/.claude/hooks/.";
  };

  config = lib.mkIf (cfg.enable && cfg.hookScripts != { }) {
    home.file = lib.listToAttrs (lib.mapAttrsToList mkHookScript cfg.hookScripts);
  };
}
