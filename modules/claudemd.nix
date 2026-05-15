{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;

  fragmentSubmodule = lib.types.submodule {
    options = {
      content = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Inline fragment content.";
      };
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to fragment file.";
      };
      order = lib.mkOption {
        type = lib.types.int;
        description = "Sort order for this fragment.";
      };
    };
  };

  sortedFragments = lib.sort (a: b: a.order < b.order) cfg.claudeMd.fragments;

  orders = map (f: f.order) cfg.claudeMd.fragments;
  uniqueOrders = lib.unique orders;

  fragmentContent = f: if f.content != null then f.content else builtins.readFile f.source;

  composedContent = lib.concatStringsSep "\n" (map fragmentContent sortedFragments);
in
{
  options.programs.claude-code.claudeMd = {
    fragments = lib.mkOption {
      type = lib.types.listOf fragmentSubmodule;
      default = [ ];
      description = "Ordered fragments composing ~/.claude/CLAUDE.md.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.claudeMd.fragments != [ ]) {
    assertions = [
      {
        assertion = lib.length orders == lib.length uniqueOrders;
        message = "CLAUDE.md fragments must have unique order values";
      }
    ];

    home.file.".claude/CLAUDE.md".text = composedContent;
  };
}
