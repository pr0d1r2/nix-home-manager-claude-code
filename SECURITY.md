# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this project, please report it responsibly.

**Email:** <marcin@prodix.pl>

Please include:

- Description of the vulnerability
- Steps to reproduce
- Potential impact

You will receive an acknowledgment within 48 hours. Please do not open a public issue for security vulnerabilities.

## Scope

This project generates configuration files for Claude Code via home-manager. Security-relevant areas include:

- **Hook scripts** — executed automatically by Claude Code
- **MCP server configuration** — controls which servers Claude Code connects to
- **Permission settings** — controls what Claude Code is allowed to do
- **Merge logic** — ensures Nix-managed keys don't overwrite user secrets

## Supported Versions

Only the latest release on `main` is actively supported with security fixes.
