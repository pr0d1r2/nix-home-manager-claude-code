# Linter coverage

| Extension | Linter | Notes |
| --------- | ------ | ----- |
| `.bats` | shellcheck, bats-parse, bats-unit | Shell test files |
| `.editorconfig` | editorconfig-checker | Config file |
| `.envrc` | shellcheck | Direnv config |
| `.gitignore` | editorconfig-checker | Git config |
| `.json` | editorconfig-checker | Data files |
| `.lock` | editorconfig-checker | Flake lock |
| `.md` | markdownlint | Documentation (README, CHANGELOG, SPEC, docs/) |
| `.md` | markdownlint-agentic | Agentic files (agent/set/skills/, files/commands/, templates/) |
| `.nix` | nixfmt, statix, deadnix, nix-no-embedded-shell | Nix modules |
| `.sh` | shellcheck, shfmt, no-shell-functions | Shell scripts |
| `.yml` | yamllint | YAML config |
| `LICENSE` | editorconfig-checker | License file |
