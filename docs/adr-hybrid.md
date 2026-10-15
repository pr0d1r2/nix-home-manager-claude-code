# ADR: Hybrid module on top of upstream home-manager

Status: accepted (namespace decision, #8). Full rationale follows in #19.

## Context

home-manager ships its own `programs/claude-code.nix`. Today this flake
disables it with `disabledModules` and reimplements every option. The hybrid
migration (tracker #18) runs our module as a companion on top of upstream
instead.

`tests/hybrid.nix` proves the idea is viable. It also shows that 5 of our
option names collide with upstream on type-merge: `settings`, `hooks`,
`mcpServers`, `commands` and `plugins`.

## Decision

Our mutable-merge layer moves under one internal namespace:

```nix
programs.claude-code.mutable = {
  settings = { };       # merged into writable ~/.claude/settings.json
  mcpServers = { };     # merged into writable ~/.claude/.mcp.json
  plugins = { };        # marketplace definitions + enabledPlugins
  hooks = { };          # hook entries merged into settings.json
  blockedPlugins = [ ];
};
```

- Name: `programs.claude-code.mutable`. Upstream declares no option with this
  name (checked against home-manager `release-26.05`).
- Scope: only options whose values we merge into files that Claude Code
  rewrites at runtime. Static leaves (`commands`, and later others) delegate
  to upstream instead (#9).
- Our-only options with no upstream twin (`keybindings`, `claudeMd`,
  `statusLine`, `spinnerVerbs` and similar) keep their current names.
- Transition: each moved option gets an `mkRenamedOptionModule` alias from
  its old name. All aliases are deleted at cutover (#14), because upstream
  reclaims those names.
- `disabledModules` stays until #14.

## Consequences

- #25 creates the `mutable` submodule scaffold with this name.
- #10, #11, #12 and #13 move `settings`, `mcpServers`, `plugins` and `hooks`
  into it, one PR each, based on `feat/hybrid`.
- Users get deprecation warnings during the transition and must rename their
  config before #14.
