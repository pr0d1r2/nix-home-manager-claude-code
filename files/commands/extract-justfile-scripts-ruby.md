Extract embedded shell code from justfile recipes into separate script files, then generate test coverage. This variant is for Ruby projects (detected by presence of Gemfile).

## Process

1. **Read the justfile** (and any `justfile.d/*.mod.just` files) in the current project
2. **Identify recipes with embedded shell** — any recipe with more than a single command line (multi-line shell blocks)
3. **For each embedded script:**
   - Extract the shell code to `scripts/<namespace>/<recipe-name>.sh` (use the justfile module name as namespace, or derive from existing directory conventions)
   - Make the script executable (`chmod +x`)
   - Add `set -euo pipefail` if not already present
   - Replace the justfile recipe body with `bash {{scripts}}/<namespace>/<recipe-name>.sh` (passing any recipe arguments as `$1`, `$2`, etc.)
   - Preserve any justfile variable interpolation (`{{var}}`) by converting to script arguments
4. **Verify** the justfile still parses correctly: `just --list`
5. **Chain to coverage sub-skill** — run `/cover-rb` to generate RSpec tests for the newly extracted scripts

## Rules

- Do NOT extract single-line recipes (e.g., `build: bash scripts/build.sh`)
- Do NOT extract recipes that are just calling another just recipe
- Preserve the `scripts` variable convention: `scripts := justfile_directory() / "scripts"`
- Keep recipe comments/descriptions in the justfile
- If a script already exists at the target path, show the diff and ask before overwriting
- Commit after extraction with message describing what was extracted
- The coverage commit from `/cover-rb` should be a separate follow-up commit
