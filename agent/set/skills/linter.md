# Linter

Every file type tracked in git must have an assigned linter in lefthook.yml (both pre-commit and pre-push). When adding a new file type to the repo, add its linter before committing.

## Current coverage

| Extension | Linter | Notes |
| --------- | ------ | ----- |
| `.nix` | statix, deadnix, nixfmt | Three complementary checks |
| `.sh` | shellcheck, shfmt | Correctness + format |
| `.bats` | shellcheck, `bats -c` | Correctness + parse-only validation |
| `.md` | markdownlint | Config in `.markdownlint.jsonc` |
| `.yml` | yamllint | Config in `.yamllint.yml` |
| `.json` | — | Validated by consuming tools |
| `.lock` | — | Generated file, no lint needed |
| `.gitignore` | — | Trivial format, no lint needed |
| `.envrc` | — | Sourced by direnv |
| `.editorconfig` | — | INI-like format, validated by editors |
| `LICENSE` | — | Legal text, no lint needed |

## Adding a new linter

1. Add the tool to both devShells in `flake.nix`
2. Add a command to both `pre-commit` and `pre-push` in `lefthook.yml`
3. Use `glob` to scope to the right file extensions
4. Pre-commit: lint `{staged_files}` only; pre-push: lint all tracked files
5. Fix any existing violations before committing
6. Update this table
