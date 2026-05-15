{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;

  ruleSubmodule = lib.types.submodule {
    options = {
      content = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Inline rule content.";
      };
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to rule file.";
      };
    };
  };

  mkRuleFile = name: rule: {
    name = ".claude/rules/${name}.md";
    value = if rule.content != null then { text = rule.content; } else { inherit (rule) source; };
  };
in
{
  options.programs.claude-code.rules = lib.mkOption {
    type = lib.types.attrsOf ruleSubmodule;
    default = { };
    description = "Rule files placed at ~/.claude/rules/.";
  };

  config = lib.mkIf (cfg.enable && cfg.rules != { }) {
    home.file = lib.listToAttrs (lib.mapAttrsToList mkRuleFile cfg.rules);
  };
}
