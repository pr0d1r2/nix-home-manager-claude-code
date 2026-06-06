{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.claude-code;

  stdioFields = {
    command = lib.mkOption {
      type = lib.types.str;
      description = "Command to run.";
    };
    args = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Arguments to command.";
    };
    env = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Environment variables.";
    };
  };

  httpFields = {
    url = lib.mkOption {
      type = lib.types.str;
      description = "Server URL.";
    };
    headers = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "HTTP headers.";
    };
    headersHelper = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Helper command for dynamic headers.";
    };
    oauth = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      default = null;
      description = "OAuth configuration.";
    };
  };

  mcpServerSubmodule = lib.types.submodule {
    options = {
      type = lib.mkOption {
        type = lib.types.enum [
          "stdio"
          "http"
          "streamable-http"
          "sse"
        ];
        description = "MCP server transport type.";
      };
      alwaysLoad = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Always load this server.";
      };
    }
    // stdioFields
    // httpFields;
  };

  mkMcpEntry =
    _: srv:
    let
      base = {
        inherit (srv) type;
      }
      // lib.optionalAttrs (srv.alwaysLoad != null) { inherit (srv) alwaysLoad; };
      stdioAttrs = lib.optionalAttrs (srv.type == "stdio") (
        {
          inherit (srv) command;
        }
        // lib.optionalAttrs (srv.args != [ ]) { inherit (srv) args; }
        // lib.optionalAttrs (srv.env != { }) { inherit (srv) env; }
      );
      httpAttrs = lib.optionalAttrs (srv.type != "stdio") (
        {
          inherit (srv) url;
        }
        // lib.optionalAttrs (srv.headers != { }) { inherit (srv) headers; }
        // lib.optionalAttrs (srv.headersHelper != null) { inherit (srv) headersHelper; }
        // lib.optionalAttrs (srv.oauth != null) { inherit (srv) oauth; }
      );
    in
    base // stdioAttrs // httpAttrs;

  mcpConfig = {
    mcpServers = lib.mapAttrs mkMcpEntry cfg.mcpServers;
  };

  mergeScript = pkgs.replaceVars ../lib/run-merge-mcp.sh {
    jq = "${pkgs.jq}/bin";
    coreutils = "${pkgs.coreutils}/bin";
    nixMcp = builtins.toJSON mcpConfig;
    mergeScript = pkgs.writeText "merge-mcp.sh" (builtins.readFile ../lib/merge-mcp.sh);
  };
in
{
  options.programs.claude-code.mcpServers = lib.mkOption {
    type = lib.types.attrsOf mcpServerSubmodule;
    default = { };
    description = "MCP server definitions merged into .mcp.json.";
  };

  config = lib.mkIf (cfg.enable && cfg.mcpServers != { }) {
    home.activation.claudeMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD bash ${mergeScript}
    '';
  };
}
