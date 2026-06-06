{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.claude-code;
  buildMarketplace = import ../lib/build-marketplace.nix pkgs;

  pluginSubmodule = lib.types.submodule {
    options = {
      src = lib.mkOption {
        type = lib.types.either lib.types.package lib.types.path;
        description = "Marketplace repo root (package or path).";
      };
      marketplace = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Marketplace name. Defaults to attr name.";
      };
      subPlugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Sub-plugin dirs within marketplace.";
      };
    };
  };

  mkMarketplace =
    name: pluginCfg:
    let
      mName = if pluginCfg.marketplace != "" then pluginCfg.marketplace else name;
      subs = if pluginCfg.subPlugins != [ ] then pluginCfg.subPlugins else [ name ];
    in
    buildMarketplace {
      name = mName;
      inherit (pluginCfg) src;
      subPlugins = subs;
    };

  marketplaces = lib.mapAttrs mkMarketplace cfg.plugins;

  enabledPluginIds = lib.concatMap (
    drv: map (sub: "${sub}@${drv.passthru.marketplaceName}") drv.passthru.subPlugins
  ) (lib.attrValues marketplaces);

  extraKnownMarketplaces = lib.listToAttrs (
    map (drv: {
      name = drv.passthru.marketplaceName;
      value = {
        source = "local-path";
        path = "~/.claude/nix-plugins/${drv.passthru.marketplaceName}";
      };
    }) (lib.attrValues marketplaces)
  );

  managedNames = lib.concatStringsSep " " (lib.attrNames marketplaces);

  cleanCacheScript = pkgs.replaceVars ../lib/run-clean-plugin-cache.sh {
    coreutils = "${pkgs.coreutils}/bin";
    inherit managedNames;
    cleanScript = pkgs.writeText "clean-plugin-cache.sh" (
      builtins.readFile ../lib/clean-plugin-cache.sh
    );
  };

  cleanDataScript = pkgs.replaceVars ../lib/run-clean-plugin-data.sh {
    coreutils = "${pkgs.coreutils}/bin";
    managedPlugins = managedNames;
    cleanScript = pkgs.writeText "clean-plugin-data.sh" (builtins.readFile ../lib/clean-plugin-data.sh);
  };

  mergeBlocklistScript = pkgs.replaceVars ../lib/run-merge-blocklist.sh {
    jq = "${pkgs.jq}/bin";
    coreutils = "${pkgs.coreutils}/bin";
    nixBlocked = builtins.toJSON cfg.blockedPlugins;
    mergeScript = pkgs.writeText "merge-blocklist.sh" (builtins.readFile ../lib/merge-blocklist.sh);
  };
in
{
  options.programs.claude-code = {
    plugins = lib.mkOption {
      type = lib.types.attrsOf pluginSubmodule;
      default = { };
      description = "Plugin marketplace definitions.";
    };

    blockedPlugins = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Plugin IDs to block (e.g. \"name@marketplace\").";
    };

    cleanPluginData = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Remove plugin data dirs for plugins no longer in config.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.blockedPlugins != [ ]) {
      home.activation.claudeBlocklist = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD bash ${mergeBlocklistScript}
      '';
    })

    (lib.mkIf (cfg.enable && cfg.cleanPluginData && cfg.plugins != { }) {
      home.activation.claudeCleanPluginData = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD bash ${cleanDataScript}
      '';
    })

    (lib.mkIf (cfg.enable && cfg.plugins != { }) {
      programs.claude-code = {
        _internal.enabledPlugins = enabledPluginIds;
        settings.extraKnownMarketplaces = extraKnownMarketplaces;
      };

      home.activation.claudeCleanPluginCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD bash ${cleanCacheScript}
      '';

      home.file = lib.listToAttrs (
        map (drv: {
          name = ".claude/nix-plugins/${drv.passthru.marketplaceName}";
          value = {
            source = "${drv}";
            recursive = true;
          };
        }) (lib.attrValues marketplaces)
      );
    })
  ];
}
