# Contributing to nix-home-manager-claude-code

Thank you for your interest in contributing! This guide covers the basics.

## Development Setup

```bash
# Clone and enter dev shell
git clone https://github.com/pr0d1r2/nix-home-manager-claude-code.git
cd nix-home-manager-claude-code
direnv allow   # or: nix develop
```

## Running Tests

```bash
# Unit tests (bats)
bats tests/unit/

# Full check (includes nix eval tests)
nix flake check
```

## Making Changes

1. Fork the repository and create a feature branch from `main`.
2. Make your changes — prefer small, focused commits.
3. Ensure `nix flake check` passes.
4. Run `bats tests/unit/` to verify unit tests pass.
5. Open a pull request against `main`.

## Commit Messages

This project uses [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` new features
- `fix:` bug fixes
- `docs:` documentation changes
- `test:` adding or updating tests
- `chore:` maintenance tasks
- `refactor:` code restructuring
- `ci:` CI/CD changes

## Code Style

- Nix code is formatted with `nixfmt`.
- Shell scripts are checked with `shellcheck`.
- Lefthook runs pre-commit checks automatically in the dev shell.

## Reporting Issues

Open an issue on GitHub with:

- What you expected to happen
- What actually happened
- Steps to reproduce
- Your Nix/home-manager version

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
