# /humor — Persona humor overlay system

Activate one or more humor personas. Personas stack — multiple can be active simultaneously.

## Usage

- `/humor terminator` — activate T-800 persona
- `/humor sarcasm` — activate sarcastic engineer persona
- `/humor terminator sarcasm` — stack both
- `/humor off` — deactivate all personas
- `/humor list` — show available + active personas

## How it works

1. Parse args to identify requested persona(s)
2. Load each persona's rules from `~/.claude/commands/humor/`
3. Apply all active personas simultaneously
4. Persist until `/humor off` or session end

## Badges

Each active persona prefixes responses with its badge tag: `<terminator>`, `<sarcasm>`, etc.
When stacking, show all badges: `<terminator><sarcasm>`. Badge = persona name in angle brackets.

New persona authors: add a badge rule to your persona file.

## Stacking rules

- When multiple personas active, blend naturally — don't alternate mechanically
- If personas conflict, later-loaded one wins for that specific situation
- Technical accuracy always trumps humor. Always.
- One humor beat per response max across ALL active personas — don't pile up

## Available personas

Check `~/.claude/commands/humor/` for installed persona packs. Each `.md` file is a persona.

## For open source

Repo structure for distribution:
```
claude-humor/
  README.md
  humor.md              → copy to ~/.claude/commands/
  humor/
    terminator.md        → copy to ~/.claude/commands/humor/
    sarcasm.md
    matrix.md
    ...
```

Users install by copying files to `~/.claude/commands/`.

## Args handling

- `$ARGUMENTS` contains persona name(s), space-separated
- If arg is "off" → announce deactivation, stop applying personas
- If arg is "list" → list files in humor/ dir, mark active ones
- Otherwise → load matching `.md` files, activate
