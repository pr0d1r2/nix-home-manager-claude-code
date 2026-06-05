{
  pkgs,
  home-manager,
  claude-code-package ? null,
}:
let
  mkConfig =
    config:
    (home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        { disabledModules = [ "programs/claude-code.nix" ]; }
        ../modules/default.nix
        {
          home = {
            username = "testuser";
            homeDirectory = "/home/testuser"; # nolocalpath
            stateVersion = "25.11";
          };
        }
        config
      ];
    }).config.home.activationPackage;

  basic = mkConfig {
    programs.claude-code = {
      enable = true;
      hookScripts."test-hook.sh".text = "echo hello";
      commands."test-cmd".content = "Test command";
      rules."test-rule".content = "Test rule";
      keybindings = [
        {
          key = "ctrl+k";
          command = "test";
        }
      ];
      claudeMd.fragments = [
        {
          content = "# Integration test";
          order = 0;
        }
      ];
      settings.theme = "dark";
      mcpServers.test-server = {
        type = "stdio";
        command = "test-cmd";
      };
      presets.security = true;
      credentials.source = pkgs.writeText "test-credentials" "{}";
    };
  };

  presetsAll = mkConfig {
    programs.claude-code = {
      enable = true;
      presets.all = true;
      presets.doomer = true;
    };
  };

  withPackage =
    if claude-code-package != null then
      mkConfig {
        programs.claude-code = {
          enable = true;
          package = claude-code-package;
        };
      }
    else
      null;
in
pkgs.runCommand "integration-tests"
  {
    nativeBuildInputs = [
      basic
      presetsAll
    ]
    ++ (if withPackage != null then [ withPackage ] else [ ]);
  }
  (
    ''
      bash ${../tests/check-integration.sh} "${basic}"
      bash ${../tests/check-presets-all.sh} "${presetsAll}"
    ''
    + (
      if withPackage != null then
        ''
          bash ${../tests/check-claude-code-package.sh} "${withPackage}"
        ''
      else
        ""
    )
    + ''
      touch $out
    ''
  )
