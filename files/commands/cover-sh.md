Generate bats test coverage for uncovered shell scripts.

## Process

1. **Find uncovered shell scripts** — scan `scripts/` (and any other directories with `.sh` files) for scripts that lack corresponding bats tests in `test/`
   - A script `scripts/foo/bar.sh` is covered if `test/foo/bar.bats` or `test/bar.bats` exists
   - If called with a specific file argument, only cover that file
2. **For each uncovered script**, create a bats test file:
   - Place in `test/` mirroring the script's directory structure
   - Test that the script exists and is executable
   - Test that it starts with proper shebang (`#!/usr/bin/env bash`)
   - Test that it uses strict mode (`set -euo pipefail`)
   - Analyze the script's logic and add functional tests:
     - Mock external commands (ssh, nix, rsync, etc.) using bats helper functions
     - Test argument validation and error paths
     - Test expected output for key scenarios
   - Follow existing test patterns if `test/` already has `.bats` files
3. **Verify** tests pass: `bats test/<new-test>.bats`

## Rules

- Only generate tests for scripts that don't already have coverage
- Follow existing bats conventions in the project (check for `setup()`, helper loading patterns)
- Use `bats-support`, `bats-assert`, and `bats-file` helpers if they're already in use
- Do NOT modify the scripts themselves — only create test files
- If called as a sub-skill from `/extract-justfile-scripts`, only cover the newly extracted scripts

## Example output

For `scripts/iso/build.sh`:

```bash
#!/usr/bin/env bats

setup() {
  load 'test_helper/common-setup'
  _common_setup
}

@test "build.sh exists and is executable" {
  [ -x scripts/iso/build.sh ]
}

@test "build.sh has proper shebang" {
  head -1 scripts/iso/build.sh | grep -q '#!/usr/bin/env bash'
}

@test "build.sh uses strict mode" {
  grep -q 'set -euo pipefail' scripts/iso/build.sh
}

@test "build.sh requires configuration name argument" {
  run scripts/iso/build.sh
  [ "$status" -ne 0 ]
}
```
