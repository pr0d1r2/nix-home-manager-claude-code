{
  description = "Declarative home-manager module for Claude Code";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cavemem = {
      url = "github:pr0d1r2/nix-cavemem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-dev-shell-agentic = {
      url = "github:pr0d1r2/nix-dev-shell-agentic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-nix-flake-eval = {
      url = "github:pr0d1r2/nix-lefthook-nix-flake-eval";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-no-shell-functions = {
      url = "github:pr0d1r2/nix-lefthook-no-shell-functions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-commit-msg-lint = {
      url = "github:pr0d1r2/nix-lefthook-commit-msg-lint";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-bats-changed = {
      url = "github:pr0d1r2/nix-lefthook-bats-changed";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-linter-coverage = {
      url = "github:pr0d1r2/nix-lefthook-linter-coverage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-lefthook-markdownlint-agentic = {
      url = "github:pr0d1r2/nix-lefthook-markdownlint-agentic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      nix-dev-shell-agentic,
      ...
    }@inputs:
    let
      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems =
        f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      homeManagerModules.default = import ./modules/default.nix;

      overlays.claude-code = inputs.claude-code-nix.overlays.default;

      packages = nixpkgs.lib.genAttrs supportedSystems (system: {
        inherit (inputs.claude-code-nix.packages.${system}) claude-code;
      });

      checks = forAllSystems (pkgs: {
        eval-module = import ./tests/eval-module.nix {
          inherit pkgs;
          inherit (inputs) home-manager;
          claude-code-package =
            inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
          claude-code-overlay = inputs.claude-code-nix.overlays.default;
        };

        bats = import ./tests/bats.nix {
          inherit pkgs;
          src = ./.;
        };

        integration = import ./tests/integration.nix {
          inherit pkgs;
          inherit (inputs) home-manager;
          claude-code-package =
            inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
        };

        claude-code-binary =
          let
            inherit (inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}) claude-code;
          in
          pkgs.runCommand "claude-code-binary-check"
            {
              nativeBuildInputs = [ pkgs.bash ];
              src = ./tests/check-claude-code-binary.sh;
            }
            ''
              bash $src ${claude-code}
              touch $out
            '';

        default = pkgs.runCommand "nix-home-manager-claude-code-checks" { } ''
          touch $out
        '';
      });

      templates = {
        plugin = {
          path = ./templates/plugin;
          description = "Claude Code plugin scaffold";
        };
        marketplace = {
          path = ./templates/marketplace;
          description = "Claude Code marketplace scaffold";
        };
      };

      devShells = forAllSystems (
        pkgs:
        nix-dev-shell-agentic.lib.mkShells {
          inherit pkgs inputs;
        }
      );
    };
}
