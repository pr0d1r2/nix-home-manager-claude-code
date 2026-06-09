{
  description = "Declarative home-manager module for Claude Code";

  nixConfig = {
    extra-substituters = [ "https://pr0d1r2.cachix.org" ];
    extra-trusted-public-keys = [ "pr0d1r2.cachix.org-1:NfWjbhgAj41byXhCKiaE+av3Vnphm1fTezHXEGsiQIM=" ];
  };

  inputs = {
    nixpkgs-lock.url = "github:pr0d1r2/nixpkgs-lock";
    nixpkgs.follows = "nixpkgs-lock/nixpkgs";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-cavemem = {
      url = "github:pr0d1r2/nix-cavemem";
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
    nix-lefthook-git-conflict-markers-src = {
      url = "github:pr0d1r2/nix-lefthook-git-conflict-markers";
      flake = false;
    };
    nix-lefthook-git-no-local-paths-src = {
      url = "github:pr0d1r2/nix-lefthook-git-no-local-paths";
      flake = false;
    };
    nix-lefthook-markdownlint-src = {
      url = "github:pr0d1r2/nix-lefthook-markdownlint";
      flake = false;
    };
    nix-lefthook-missing-final-newline-src = {
      url = "github:pr0d1r2/nix-lefthook-missing-final-newline";
      flake = false;
    };
    nix-lefthook-nix-no-embedded-shell-src = {
      url = "github:pr0d1r2/nix-lefthook-nix-no-embedded-shell";
      flake = false;
    };
    nix-lefthook-statix-src = {
      url = "github:pr0d1r2/nix-lefthook-statix";
      flake = false;
    };
    nix-lefthook-trailing-whitespace-src = {
      url = "github:pr0d1r2/nix-lefthook-trailing-whitespace";
      flake = false;
    };
    nix-lefthook-deadnix-src = {
      url = "github:pr0d1r2/nix-lefthook-deadnix";
      flake = false;
    };
    nix-lefthook-editorconfig-checker-src = {
      url = "github:pr0d1r2/nix-lefthook-editorconfig-checker";
      flake = false;
    };
    nix-lefthook-nixfmt-src = {
      url = "github:pr0d1r2/nix-lefthook-nixfmt";
      flake = false;
    };
    nix-lefthook-shellcheck-src = {
      url = "github:pr0d1r2/nix-lefthook-shellcheck";
      flake = false;
    };
    nix-lefthook-shfmt-src = {
      url = "github:pr0d1r2/nix-lefthook-shfmt";
      flake = false;
    };
    nix-lefthook-typos-src = {
      url = "github:pr0d1r2/nix-lefthook-typos";
      flake = false;
    };
    nix-lefthook-yamllint-src = {
      url = "github:pr0d1r2/nix-lefthook-yamllint";
      flake = false;
    };
    nix-lefthook-ascii-only-src = {
      url = "github:pr0d1r2/nix-lefthook-ascii-only";
      flake = false;
    };
    nix-lefthook-file-size-check-src = {
      url = "github:pr0d1r2/nix-lefthook-file-size-check";
      flake = false;
    };
    nix-lefthook-gitleaks-src = {
      url = "github:pr0d1r2/nix-lefthook-gitleaks";
      flake = false;
    };
    nix-lefthook-unicode-lint-src = {
      url = "github:pr0d1r2/nix-lefthook-unicode-lint";
      flake = false;
    };
    nix-lefthook-execute-permissions-src = {
      url = "github:pr0d1r2/nix-lefthook-execute-permissions";
      flake = false;
    };
    nix-lefthook-tdd-order-bats-src = {
      url = "github:pr0d1r2/nix-lefthook-tdd-order-bats";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nix-lefthook-git-conflict-markers-src,
      nix-lefthook-git-no-local-paths-src,
      nix-lefthook-markdownlint-src,
      nix-lefthook-missing-final-newline-src,
      nix-lefthook-nix-no-embedded-shell-src,
      nix-lefthook-statix-src,
      nix-lefthook-trailing-whitespace-src,
      nix-lefthook-deadnix-src,
      nix-lefthook-editorconfig-checker-src,
      nix-lefthook-nixfmt-src,
      nix-lefthook-shellcheck-src,
      nix-lefthook-shfmt-src,
      nix-lefthook-typos-src,
      nix-lefthook-yamllint-src,
      nix-lefthook-ascii-only-src,
      nix-lefthook-file-size-check-src,
      nix-lefthook-gitleaks-src,
      nix-lefthook-unicode-lint-src,
      nix-lefthook-execute-permissions-src,
      nix-lefthook-tdd-order-bats-src,
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

      lefthookPackagesFrom =
        system:
        nixpkgs.lib.mapAttrsToList (_: input: input.packages.${system}.default) (
          nixpkgs.lib.filterAttrs (
            name: input: nixpkgs.lib.hasPrefix "nix-lefthook-" name && input ? packages
          ) inputs
        );

      lefthookWrappersFor =
        pkgs:
        let
          wrap =
            name: src: extra:
            pkgs.writeShellApplication (
              {
                inherit name;
                text = builtins.readFile "${src}/${name}.sh";
              }
              // extra
            );
        in
        [
          (wrap "lefthook-git-conflict-markers" nix-lefthook-git-conflict-markers-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (wrap "lefthook-git-no-local-paths" nix-lefthook-git-no-local-paths-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (wrap "lefthook-markdownlint" nix-lefthook-markdownlint-src {
            runtimeInputs = [ pkgs.markdownlint-cli ];
          })
          (wrap "lefthook-missing-final-newline" nix-lefthook-missing-final-newline-src { })
          (pkgs.writeShellApplication {
            name = "lefthook-nix-no-embedded-shell";
            text = ''
              SCANNER="${nix-lefthook-nix-no-embedded-shell-src}/scan-nix-no-embedded-shell.sh"
            ''
            + builtins.readFile "${nix-lefthook-nix-no-embedded-shell-src}/lefthook-nix-no-embedded-shell.sh";
          })
          (wrap "lefthook-statix" nix-lefthook-statix-src {
            runtimeInputs = [ pkgs.statix ];
          })
          (wrap "lefthook-trailing-whitespace" nix-lefthook-trailing-whitespace-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (wrap "lefthook-deadnix" nix-lefthook-deadnix-src {
            runtimeInputs = [ pkgs.deadnix ];
          })
          (wrap "lefthook-editorconfig-checker" nix-lefthook-editorconfig-checker-src {
            runtimeInputs = [ pkgs.editorconfig-checker ];
          })
          (wrap "lefthook-nixfmt" nix-lefthook-nixfmt-src {
            runtimeInputs = [ pkgs.nixfmt ];
          })
          (wrap "lefthook-shellcheck" nix-lefthook-shellcheck-src {
            runtimeInputs = [ pkgs.shellcheck ];
          })
          (wrap "lefthook-shfmt" nix-lefthook-shfmt-src {
            runtimeInputs = [ pkgs.shfmt ];
          })
          (wrap "lefthook-typos" nix-lefthook-typos-src {
            runtimeInputs = [ pkgs.typos ];
          })
          (wrap "lefthook-yamllint" nix-lefthook-yamllint-src {
            runtimeInputs = [ pkgs.yamllint ];
          })
          (wrap "lefthook-ascii-only" nix-lefthook-ascii-only-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (wrap "get-file-size-limit" nix-lefthook-file-size-check-src {
            runtimeInputs = [
              pkgs.gawk
              pkgs.gnugrep
            ];
          })
          (pkgs.writeShellApplication {
            name = "lefthook-file-size-check";
            runtimeInputs = [
              pkgs.gawk
              pkgs.gnugrep
              pkgs.coreutils
              (wrap "get-file-size-limit" nix-lefthook-file-size-check-src {
                runtimeInputs = [
                  pkgs.gawk
                  pkgs.gnugrep
                ];
              })
            ];
            text = builtins.readFile "${nix-lefthook-file-size-check-src}/lefthook-file-size-check.sh";
          })
          (wrap "lefthook-gitleaks" nix-lefthook-gitleaks-src {
            runtimeInputs = [
              pkgs.gitleaks
              pkgs.coreutils
            ];
          })
          (wrap "lefthook-unicode-lint" nix-lefthook-unicode-lint-src {
            runtimeInputs = [
              pkgs.gnugrep
              pkgs.libiconv
              pkgs.python3
              pkgs.perl
            ];
          })
          (wrap "lefthook-execute-permissions" nix-lefthook-execute-permissions-src {
            runtimeInputs = [ pkgs.gnugrep ];
          })
          (wrap "lefthook-tdd-order-bats" nix-lefthook-tdd-order-bats-src { })
        ];

      baseCiPackagesFor = pkgs: [
        pkgs.coreutils
        pkgs.deadnix
        pkgs.editorconfig-checker
        pkgs.git
        pkgs.gitleaks
        pkgs.lefthook
        pkgs.nix
        pkgs.nixfmt
        pkgs.parallel
        pkgs.shellcheck
        pkgs.shfmt
        pkgs.statix
        pkgs.typos
        pkgs.yamllint
      ];

      batsWithLibsFor =
        pkgs:
        pkgs.bats.withLibraries (p: [
          p.bats-support
          p.bats-assert
          p.bats-file
        ]);
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

        integration = import ./tests/integration.nix {
          inherit pkgs;
          inherit (inputs) home-manager;
          claude-code-package =
            inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
        };

        claude-code-binary = import ./tests/claude-code-binary.nix {
          inherit pkgs;
          inherit (inputs.claude-code-nix.packages.${pkgs.stdenv.hostPlatform.system}) claude-code;
        };

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
        let
          inherit (pkgs.stdenv.hostPlatform) system;
          batsWithLibs = batsWithLibsFor pkgs;
          allCiPackages =
            (lefthookWrappersFor pkgs)
            ++ (lefthookPackagesFrom system)
            ++ (baseCiPackagesFor pkgs)
            ++ [ batsWithLibs ];
        in
        {
          ci = pkgs.mkShell {
            packages = allCiPackages;
            BATS_LIB_PATH = "${batsWithLibs}/share/bats";
          };
          default = pkgs.mkShell {
            packages = allCiPackages ++ [
              inputs.nix-cavemem.packages.${system}.default
              pkgs.gh
              pkgs.nodejs
            ];
            shellHook = ''
              export NIX_CONFIG="experimental-features = nix-command flakes"
              [ -f .git/hooks/pre-commit ] || lefthook install
            '';
          };
          inherit batsWithLibs;
        }
      );
    };
}
