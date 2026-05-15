{
  claudeModule,
  lib,
  sets,
}:

{
  set ? { },
  setting ? { },
  infrastructure ? { },
}:

{ pkgs, ... }:

let
  setDefaults = {
    categories = builtins.attrNames sets;
  };

  settingDefaults = {
    model = "claude-opus-4-6";
    thinkingBudget = "medium";
    presets = {
      autoCommit = true;
      coverage = true;
      justfile = true;
      sessionId = true;
    };
    settings = {
      buddyEnabled = false;
      promptSuggestionEnabled = false;
    };
    env.CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1";
  };

  infraDefaults = {
    editorconfig = true;
    gitattributes = true;
    gitignore = [
      "nix"
      "claude"
    ];
  };

  mergedSet = setDefaults // set;
  mergedSetting = pkgs.lib.recursiveUpdate settingDefaults setting;
  mergedInfra = infraDefaults // infrastructure;

  skillSet = lib.mkSet (mergedSet // { inherit pkgs; });
  infra = lib.mkSetting (mergedInfra // { inherit pkgs; });
in
{
  disabledModules = [ "programs/claude-code.nix" ];
  imports = [ claudeModule ];

  options.set-and-setting = {
    skillSet = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
      default = skillSet;
      readOnly = true;
      description = "Built skill set derivation.";
    };
    infrastructure = pkgs.lib.mkOption {
      type = pkgs.lib.types.package;
      default = infra;
      readOnly = true;
      description = "Built infrastructure standards derivation.";
    };
  };

  config.programs.claude-code = {
    enable = true;
  }
  // mergedSetting;
}
