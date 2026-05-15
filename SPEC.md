# SPEC

## §G Goal

Declarative home-manager module for Claude Code config — plugins, settings, MCP servers, hooks, hook scripts, commands, rules, CLAUDE.md, keybindings, permissions, statusLine, package. Nix-managed, merge-safe with mutable `~/.claude/` files. Hub for all Claude Code Nix config, consumed by nix-config.

## §C Constraints

- C1: Pure Nix — home-manager module, no wrapper scripts at runtime
- C2: Nix flake — `homeManagerModules.default` + `checks` outputs
- C3: ⊥ clobber user's manual `settings.json` / `.mcp.json` edits — activation merge only
- C4: Plugin sources via flake inputs (`fetchgit`, `fetchFromGitLab`, local paths)
- C5: MIT license
- C6: Package option available but optional — users may install claude separately
- C7: ⊥ touch `~/.claude/projects/` or memory files
- C8: Caveman-encoded spec & docs
- C9: Project-level `.claude/settings.json` out of scope — separate concern
- C10: Plugin delivery via `extraKnownMarketplaces` local-path source → Claude Code copies to cache (official mechanism)
- C11: Migration — copy existing `~/.claude/` managed files into repo, ⊥ move. Provide `migrate.sh` that renames old files to `*.backup` + prints `home.file` entries to remove from nix-config
- C12: ∀ hook script with external deps → `pkgs.replaceVars` with `@placeholder@` syntax for Nix store paths. Scripts without deps use plain `home.file`. ⊥ rely on ambient PATH for managed binaries
- C13: CI via GitHub Actions + cachix (same pattern as other pr0d1r2 repos)

## §I Interfaces

### Module

- I.mod: `homeManagerModules.default` — main home-manager module import
- I.checks: `checks.<system>.default` — eval tests + merge script unit tests

### Options — core

- I.opt.enable: `programs.claude-code.enable` → bool, gate all config
- I.opt.package: `programs.claude-code.package` → nullable package, adds to `home.packages` when set

### Templates

- I.tpl.plugin: `templates.plugin` — scaffold single-plugin repo (flake.nix, plugin.json, sample command/skill)
- I.tpl.marketplace: `templates.marketplace` — scaffold multi-plugin marketplace repo (flake.nix, marketplace.json, sample sub-plugins)

### Plugins

- I.opt.plugins: `programs.claude-code.plugins` → attrset of plugin defs
  - `src` → package or path (marketplace repo root)
  - `marketplace` → str (defaults to attr name)
  - `subPlugins` → list of str (sub-plugin dirs within marketplace, defaults to `[ name ]`)
- I.opt.blockedPlugins: `programs.claude-code.blockedPlugins` → list of str (plugin IDs like `"name@marketplace"`)
- I.opt.cleanPluginData: `programs.claude-code.cleanPluginData` → bool (default false). When true, activation also clears `~/.claude/plugins/data/` for removed plugins. Purist mode.

### Settings — typed

- I.opt.model: `programs.claude-code.model` → nullable str. Applied via `lib.mkDefault` → freeform `settings.model` overrides if set
- I.opt.thinkingBudget: `programs.claude-code.thinkingBudget` → nullable enum (`"none"` | `"low"` | `"medium"` | `"high"` | `"max"`). Applied via `lib.mkDefault`
- I.opt.env: `programs.claude-code.env` → attrset of str (env vars, e.g. `{ CLAUDE_CODE_DISABLE_FEEDBACK_SURVEY = "1"; }`). Applied via `lib.mkDefault`
- I.opt.promptSuggestions: `programs.claude-code.promptSuggestions` → nullable bool. Applied via `lib.mkDefault`
- I.opt.buddyMode: `programs.claude-code.buddyMode` → nullable bool. Applied via `lib.mkDefault`

### Settings — freeform

- I.opt.settings: `programs.claude-code.settings` → freeform attrs merged into `~/.claude/settings.json`. Normal priority — **overrides typed options** (typed use `lib.mkDefault`)
- I.opt.spinner: `programs.claude-code.spinnerVerbs` → `{ mode: enum "replace"|"append", verbs: [str] }`

### Permissions

- I.opt.permissions: `programs.claude-code.permissions` → typed permission rules
  - `allow` → list of str (auto-approve patterns, e.g. `"Bash(git *)"`, `"Read"`, `"WebFetch(domain:example.com)"`)
  - `ask` → list of str (prompt-per-use patterns)
  - `deny` → list of str (block patterns — evaluated first, wins over allow/ask)
- I.opt.defaultMode: `programs.claude-code.defaultMode` → enum `"default"` | `"acceptEdits"` | `"plan"` | `"auto"` | `"dontAsk"` | `"bypassPermissions"`
- I.opt.additionalDirectories: `programs.claude-code.additionalDirectories` → list of str (extra paths Claude can access)

### MCP Servers

- I.opt.mcp: `programs.claude-code.mcpServers` → attrset of typed MCP server defs
  - `type` → enum `"stdio"` | `"http"` | `"streamable-http"` | `"sse"`
  - stdio fields: `command`, `args`, `env`
  - http fields: `url`, `headers`, `oauth`, `headersHelper`
  - shared: `alwaysLoad`

### Hooks

- I.opt.hooks: `programs.claude-code.hooks` → attrset of event → entry list, typed
  - event key → enum of all Claude Code hook events (see §V.23)
  - each entry: `{ matcher: str, hooks: [hookAction] }`
  - hookAction: `{ type: enum, command?, args?, timeout?, statusMessage?, url?, headers?, tool?, input?, prompt?, parseJson? }`
  - hook types: `"command"` | `"http"` | `"mcp_tool"` | `"prompt"`

### Status Line

- I.opt.statusLine: `programs.claude-code.statusLine` → nullable typed option (separate from hooks)
  - `command` → str (script path or inline command)
  - `padding` → int (default 0)
  - `refreshInterval` → nullable int (seconds, min 1)
  - `hideVimModeIndicator` → bool (default false)

### Hook Scripts

- I.opt.hookScripts: `programs.claude-code.hookScripts` → attrset of script defs
  - template mode: `{ source: path, vars: attrset }` → built via `pkgs.replaceVars` (e.g. `{ rtk = "${rtkPkg}/bin/rtk"; }`)
  - plain mode: `{ source: path }` → direct `home.file` (no substitution)
  - text mode: `{ text: str }` → `pkgs.writeScript`
  - placed at `~/.claude/hooks/<name>` via `home.file` (symlink to store)
  - module provides `lib.mkDefault` → user can override individual scripts

### CLAUDE.md & Rules

- I.opt.claudeMd: `programs.claude-code.claudeMd` → composable global `~/.claude/CLAUDE.md`
  - `fragments` → list of `{ content: str, order: int }` or `{ source: path, order: int }`
  - concatenated in order → final CLAUDE.md
  - `fragments = []` (default) → ⊥ manage CLAUDE.md, leave existing file untouched
  - `fragments` non-empty → `home.file` owns `~/.claude/CLAUDE.md`
  - assertion: ∀ order values unique — duplicate orders → eval error with clear message
  - presets can append fragments (e.g. caveman preset adds `@RTK.md` reference)
- I.opt.rules: `programs.claude-code.rules` → attrset of rule file defs
  - each entry: `{ content: str }` or `{ source: path }`
  - placed at `~/.claude/rules/<name>.md` via `home.file`

### Commands & Keybindings

- I.opt.commands: `programs.claude-code.commands` → attrset of command defs
  - flat: `commands.cover-sh = { content: str }` or `{ source: path }` → `~/.claude/commands/cover-sh.md`
  - nested: `commands.humor = { source: path, recursive: true }` → copies dir to `~/.claude/commands/humor/`
  - `/`-key: `commands."humor/sarcasm" = { content: str }` → `~/.claude/commands/humor/sarcasm.md`
- I.opt.keybindings: `programs.claude-code.keybindings` → list of keybinding defs

### Presets

- I.opt.presets: `programs.claude-code.presets` → attrset of bool toggles
  - `presets.caveman` → installs caveman hooks (UserPromptSubmit + SessionStart context injection)
  - `presets.doomer` → sets doomer spinnerVerbs (replace mode, 18 self-deprecating verbs)
  - `presets.skeptic` → sets skeptic spinnerVerbs (replace mode, trust-nothing verbs)
  - `presets.security` → adds deny rules for destructive ops (`"Bash(rm -rf *)"`, `"Bash(git push --force *)"`, `"Bash(git reset --hard *)"`, `"Bash(git clean -f*)"`)
  - `presets.doomer` & `presets.skeptic` mutually exclusive — assertion error if both true

### Plugin detection

- I.detect: `scripts/detect-plugins.sh` — scans `~/.claude/plugins/cache/` for manually-installed plugins not in Nix config
  - outputs Nix snippet per detected plugin (ready to paste into `programs.claude-code.plugins`)
  - `--json` → machine-readable output
  - helps migration from manual plugin installs to declarative

### Migration

- I.migrate: `scripts/migrate.sh` — standalone script for switching from manual to module-managed config
  - `--dry-run` → lists what would be renamed, ⊥ modifies
  - `--backup` → renames `~/.claude/hooks/<name>` and `~/.claude/commands/<name>` to `*.backup`
  - `--nix-config` → prints `home.file` entries to remove from nix-config (grep-friendly)
  - scans repo `files/hooks/` + `files/commands/` for names → ⊥ hardcoded list
  - ⊥ touch `settings.json`, `.mcp.json`, `plugins/`
  - idempotent — skips already-backed-up files
  - prints summary: N files backed up, M nix-config entries to remove

### Files managed

- I.file.settings: `~/.claude/settings.json` — merge-managed via activation
- I.file.mcp: `~/.claude/.mcp.json` — merge-managed via activation
- I.file.keys: `~/.claude/keybindings.json` — owned via `home.file` (not merge-managed)
- I.file.cmds: `~/.claude/commands/<name>.md` — owned via `home.file`
- I.file.hooks: `~/.claude/hooks/<name>` — owned via `home.file` (writeShellApplication derivations)
- I.file.rules: `~/.claude/rules/<name>.md` — owned via `home.file`
- I.file.claudemd: `~/.claude/CLAUDE.md` — owned via `home.file` (composed from fragments)
- I.file.plugins: `~/.claude/nix-plugins/<marketplace>/` — Nix store marketplace layout
- I.file.managed: `~/.claude/.nix-managed-keys.json` — tracks Nix-owned settings keys
- I.file.managed-mcp: `~/.claude/.nix-managed-mcp-keys.json` — tracks Nix-owned MCP server names
- I.file.blocklist: `~/.claude/plugins/blocklist.json` — merge-managed via activation

## §V Invariants

### Merge semantics

- V1: settings.json merge → deep merge all, then **replace** `enabledPlugins` key entirely with Nix-managed set. Two-step: `jq '.[0] * .[1]'` then `jq '.enabledPlugins = $nix[0]'`
- V2: plugin removal from Nix config → `enabledPlugins` replaced wholesale → stale entries gone automatically
- V3: MCP server removal → activation reads `.nix-managed-mcp-keys.json`, deletes old managed servers from `.mcp.json`, then merges new ones
- V4: ∀ managed file write → atomic (write tmp + mv, ⊥ partial writes)
- V5: multiple `home-manager switch` → idempotent result
- V6: `~/.claude/settings.json` absent → create with managed content only
- V7: `~/.claude/.mcp.json` absent → create with managed content only

### Permissions merge

- V8: `permissions.deny` evaluated first, then `ask`, then `allow` — deny wins
- V9: permissions arrays merge via `lib.mkMerge` — presets & user config compose cleanly
- V10: `defaultMode` enum-validated at eval time

### Plugin placement

- V11: ∀ plugin marketplace → Nix derivation builds marketplace layout (marketplace.json + sub-plugin dirs)
- V12: marketplace registered via `extraKnownMarketplaces` in settings.json with `source: "local-path"`
- V13: ∀ plugin with subPlugins → each sub gets `enabledPlugins` entry
- V14: activation clears stale plugin cache dirs on rebuild → forces re-copy from updated store path
- V15: blocklist merge-managed — Nix entries added/removed, manually-blocked plugins preserved
- V16: `~/.claude/plugins/data/` ⊥ touched by default. `cleanPluginData = true` → activation removes data dirs for plugins no longer in config

### File ownership

- V17: ⊥ touch `~/.claude/projects/` or memory files
- V18: ∀ command → `~/.claude/commands/<name>.md`, content from option
- V19: keybindings.json fully owned when option set (⊥ merge — rarely mutated externally)
- V20: hooks in settings.json merge-managed same pattern as other settings keys
- V21: ∀ hook script → `writeShellApplication` with `runtimeInputs` → `home.file` symlink to store path
- V22: statusLine → separate top-level key in settings.json (⊥ under `hooks`)
- V23: ∀ rule → `~/.claude/rules/<name>.md` via `home.file`
- V24: CLAUDE.md composed from ordered fragments, owned via `home.file`

### Activation ordering

- V25: ∀ activation script → depends on `writeBoundary` (runs after `home.file` placed)

### Type safety

- V26: hook event names → enum-validated at eval time. Valid events:
  `SessionStart` `Setup` `SessionEnd`
  `UserPromptSubmit` `UserPromptExpansion` `Notification`
  `PreToolUse` `PostToolUse` `PostToolUseFailure` `PostToolBatch`
  `PermissionRequest` `PermissionDenied`
  `InstructionsLoaded` `PreCompact` `PostCompact`
  `FileChanged` `CwdChanged` `ConfigChange`
  `SubagentStart` `SubagentStop`
  `TaskCreated` `TaskCompleted` `TeammateIdle`
  `Elicitation` `ElicitationResult`
  `WorktreeCreate` `WorktreeRemove`
  `Stop` `StopFailure`
- V27: MCP server type → enum-validated (`stdio` | `http` | `streamable-http` | `sse`)
- V28: hook action type → enum-validated (`command` | `http` | `mcp_tool` | `prompt`)
- V29: spinnerVerbs mode → enum-validated (`replace` | `append`)
- V30: `model` → nullable str (accepts known models + arbitrary str for future models)
- V31: `thinkingBudget` → enum-validated (`none` | `low` | `medium` | `high` | `max`)
- V32: `defaultMode` → enum-validated at eval time
- V33: permission entries → string type (patterns too complex for Nix type validation)

### Preset composition

- V34: ∀ preset → config overlay via `lib.mkIf` — composable, ⊥ conflicts unless noted
- V35: `presets.doomer` & `presets.skeptic` → **mutually exclusive**. Nix assertion: `!(doomer && skeptic)` with message "doomer and skeptic presets both set spinnerVerbs — enable only one"
- V36: `presets.security` composes with any other preset (adds deny rules via `lib.mkMerge`)
- V37: `presets.caveman` composes with any other preset (adds hooks, ⊥ touches spinnerVerbs)

### Migration

- V38: `migrate.sh --backup` renames to `*.backup`, ⊥ deletes — user can restore manually
- V39: `migrate.sh --dry-run` → list only, ⊥ modify filesystem
- V40: `migrate.sh` idempotent — `*.backup` already exists → skip
- V41: migration list derived from repo `files/` contents — ⊥ hardcoded filenames
- V42: `migrate.sh --nix-config` → prints `home.file` attr paths to remove (e.g. `home.file.".claude/hooks/statusline.sh"`)

### Hook scripts

- V43: ∀ hook script with external deps → `pkgs.replaceVars` with `@placeholder@` → Nix store paths injected at build time. Pattern from nix-config `nix/fragments/`
- V44: module hook scripts use `lib.mkDefault` → user overrides win at higher priority
- V45: MCP server commands reference user-provided packages — module ⊥ auto-install binaries. User brings own package refs (e.g. `inputs.nix-cavemem.packages.${system}.default` for cavemem)

### Settings priority

- V46: typed options (model, thinkingBudget, env, etc.) apply via `lib.mkDefault` → freeform `settings` at normal priority overrides them
- V47: ∀ typed option set to null → ⊥ emit key in settings.json

### CLAUDE.md

- V48: `claudeMd.fragments = []` → ⊥ manage CLAUDE.md (existing file untouched)
- V49: `claudeMd.fragments` non-empty → `home.file` owns CLAUDE.md
- V50: assertion: ∀ fragment order values unique — duplicate → eval error: "CLAUDE.md fragments must have unique order values"

### Package

- V51: `package` option null → ⊥ add to `home.packages`. Non-null → added.

### Testing

- V52: ∀ merge script (`merge-settings.sh`, `merge-mcp.sh`, `merge-blocklist.sh`) → 1-to-1 bats unit test coverage
- V53: `checks.<system>.default` runs: eval tests + bats merge script tests
- V54: CI runs `nix flake check` on PR + push to main

## §T Tasks

Tasks ordered by dependency (upstream first).

id|status|task|cites
T1|x|copy hook scripts from `~/.claude/hooks/` into `files/hooks/` — 11 statusline/caveman scripts + 6 direct executables + 3 coverage.d checkers. Nix store paths replaced with `command -v`|V21,V43
T2|x|copy commands from `~/.claude/commands/` into `files/commands/` — humor/ (+ sarcasm, terminator), cover-sh.md, cover-rb.md, extract-justfile-scripts.md, extract-justfile-scripts-ruby.md|V18
T3|x|scaffold flake.nix — inputs (nixpkgs, home-manager, nix-cavemem), outputs (homeManagerModules, checks, templates)|I.mod,I.checks,V45
T4|x|`modules/default.nix` — imports sub-modules, `enable` + `package` options|I.opt.enable,V46
T5|x|`lib/build-marketplace.nix` — Nix function: plugin inputs → marketplace derivation|V11
T6|x|`lib/merge-settings.sh` — init → deep merge → replace enabledPlugins → track keys|V1,V2,V4,V5
T7|x|`lib/merge-mcp.sh` — init → clean old managed servers → merge new → track keys|V3,V4,V7
T8|x|`lib/merge-blocklist.sh` — init → clean old Nix entries → add new → preserve manual entries|V15
T9|x|`tests/merge-settings.bats` — 1-to-1 coverage: absent file, deep merge, enabledPlugins replace, idempotency, atomicity|V47,V6
T10|x|`tests/merge-mcp.bats` — 1-to-1 coverage: absent file, clean old, merge new, preserve manual, idempotency|V47,V7
T11|x|`tests/merge-blocklist.bats` — 1-to-1 coverage: absent file, add Nix entries, preserve manual, remove stale|V47
T12|x|`modules/plugins.nix` — plugin option type, marketplace derivation builder, `extraKnownMarketplaces` + `enabledPlugins` + blocklist + cleanPluginData|I.opt.plugins,I.opt.blockedPlugins,I.opt.cleanPluginData,V11,V12,V13,V14,V15,V16
T13|x|`modules/settings.nix` — freeform settings + typed (model, thinkingBudget, env, promptSuggestions, buddyMode), activation merge|I.opt.settings,I.opt.model,I.opt.thinkingBudget,I.opt.env,I.opt.promptSuggestions,I.opt.buddyMode,V1,V4,V5,V6,V30,V31
T14|x|`modules/spinner.nix` — spinnerVerbs typed option, feeds into settings|I.opt.spinner,V29
T15|x|`modules/mcp.nix` — mcpServers typed option (stdio/http/streamable-http/sse fields), `.mcp.json` activation merge|I.opt.mcp,V3,V4,V7,V27
T16|x|`modules/hooks.nix` — hooks typed option (event enum, matcher, hookAction types), feeds into settings|I.opt.hooks,V20,V26,V28
T17|x|`modules/statusline.nix` — statusLine typed option, feeds into settings|I.opt.statusLine,V22
T18|x|`modules/hook-scripts.nix` — hookScripts option with writeShellApplication + runtimeInputs, `home.file` for `~/.claude/hooks/*`|I.opt.hookScripts,V21,V43,V44
T19|x|`modules/permissions.nix` — typed allow/ask/deny lists + defaultMode enum + additionalDirectories|I.opt.permissions,I.opt.defaultMode,I.opt.additionalDirectories,V8,V9,V10,V32,V33
T20|x|`modules/commands.nix` — commands option (content \| source), `home.file` for `~/.claude/commands/*.md`|I.opt.commands,V18
T21|x|`modules/claudemd.nix` — CLAUDE.md fragment composition (ordered list → concatenated file)|I.opt.claudeMd,V24
T22|x|`modules/rules.nix` — rules option, `home.file` for `~/.claude/rules/*.md`|I.opt.rules,V23
T23|x|`modules/keybindings.nix` — keybindings option, `home.file` for `keybindings.json`|I.opt.keybindings,V19
T24|x|`modules/presets/caveman.nix` — UserPromptSubmit + SessionStart hooks|I.opt.presets,V34,V37
T25|x|`modules/presets/doomer.nix` — spinnerVerbs replace with 18 doomer verbs + mutual exclusion assertion|I.opt.presets,V34,V35
T26|x|`modules/presets/skeptic.nix` — spinnerVerbs replace with skeptic verbs + mutual exclusion assertion|I.opt.presets,V34,V35
T27|x|`modules/presets/security.nix` — deny rules for destructive ops|I.opt.presets,V8,V34,V36
T28|x|wire copied files into module defaults — hookScripts entries via writeShellApplication from `files/hooks/`, commands source from `files/commands/`|V44
T29|x|managed-keys tracking — `.nix-managed-keys.json` + `.nix-managed-mcp-keys.json` write/read/cleanup|I.file.managed,V2,V3
T30|x|`scripts/migrate.sh` — `--dry-run`, `--backup`, `--nix-config` modes. Scans `files/` for names.|I.migrate,V38,V39,V40,V41,V42
T31|x|`scripts/detect-plugins.sh` — scan `~/.claude/plugins/cache/`, output Nix snippets for undeclared plugins|I.detect
T32|x|eval tests — `nix eval` module produces expected `home.file` & activation attrs|V5,V53
T33|x|integration test — build home-manager config, verify file outputs + merge idempotency|V5,V11,V53
T34|x|CI — GitHub Actions workflow: `nix flake check` on PR + push, cachix push|V54
T35|x|`templates/plugin/` — flake.nix + plugin.json + sample command + sample skill scaffold|I.tpl.plugin
T36|x|`templates/marketplace/` — flake.nix + marketplace.json + two sample sub-plugins scaffold|I.tpl.marketplace
T37|x|README — usage examples, option reference, migration guide, preset descriptions, detect-plugins usage|-
T38|x|wire `extraKnownMarketplaces` into settings.json for marketplace plugins|V12
T39|x|wire `subPlugins` → `_internal.enabledPlugins` mapping in plugins module|V13
T40|x|plugin activation — clear stale cache dirs on rebuild|V14
T41|x|wire `merge-blocklist.sh` into activation (currently dead code)|V15
T42|x|wire `cleanPluginData` activation — remove stale plugin data dirs|V16
T43|x|hook-scripts.nix — use `writeShellApplication` with `runtimeInputs` instead of `writeScript`|V21

## §B Bugs

id|date|cause|fix
-|-|-|-
