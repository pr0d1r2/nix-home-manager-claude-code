{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.claude-code;

  hookActionSubmodule = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [
          "command"
          "http"
          "mcp_tool"
          "prompt"
        ];
        description = "Hook action type.";
      };
      command = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Command to run (for command type).";
      };
      args = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Arguments for command.";
      };
      timeout = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "Timeout in milliseconds.";
      };
      statusMessage = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Status message while running.";
      };
      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "URL (for http type).";
      };
      headers = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "HTTP headers.";
      };
      tool = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "MCP tool name (for mcp_tool type).";
      };
      input = lib.mkOption {
        type = lib.types.nullOr lib.types.attrs;
        default = null;
        description = "Input for MCP tool.";
      };
      prompt = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Prompt text (for prompt type).";
      };
      parseJson = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Parse command output as JSON.";
      };
    };
  };

  hookEntrySubmodule = lib.types.submodule {
    options = {
      matcher = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Pattern matcher for this hook entry.";
      };
      hooks = lib.mkOption {
        type = lib.types.listOf hookActionSubmodule;
        description = "Hook actions to execute.";
      };
    };
  };

  cleanAction =
    action:
    let
      base = {
        inherit (action) type;
      };
      optionals =
        lib.optionalAttrs (action.command != null) { inherit (action) command; }
        // lib.optionalAttrs (action.args != [ ]) { inherit (action) args; }
        // lib.optionalAttrs (action.timeout != null) { inherit (action) timeout; }
        // lib.optionalAttrs (action.statusMessage != null) { inherit (action) statusMessage; }
        // lib.optionalAttrs (action.url != null) { inherit (action) url; }
        // lib.optionalAttrs (action.headers != { }) { inherit (action) headers; }
        // lib.optionalAttrs (action.tool != null) { inherit (action) tool; }
        // lib.optionalAttrs (action.input != null) { inherit (action) input; }
        // lib.optionalAttrs (action.prompt != null) { inherit (action) prompt; }
        // lib.optionalAttrs (action.parseJson != null) { inherit (action) parseJson; };
    in
    base // optionals;

  cleanEntry =
    entry:
    {
      hooks = map cleanAction entry.hooks;
    }
    // lib.optionalAttrs (entry.matcher != "") { inherit (entry) matcher; };

  hooksSettings = lib.mapAttrs (_: entries: map cleanEntry entries) cfg.hooks;
in
{
  options.programs.claude-code.hooks = lib.mkOption {
    type = lib.types.attrsOf (lib.types.listOf hookEntrySubmodule);
    default = { };
    description = "Hook event definitions merged into settings.json.";
  };

  config = lib.mkIf (cfg.enable && cfg.hooks != { }) {
    programs.claude-code.settings.hooks = hooksSettings;
  };
}
