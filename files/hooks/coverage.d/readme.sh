#!/bin/bash
# Coverage checker: README consistency
# Verifies hardcoded facts in README.md match the actual project state.
# Only active in repos that have a README.md.

_CHANGED="$1"

[ -f README.md ] || exit 0

ISSUES=""

# 1. Check test count claims
README_COUNT=$(grep -oE '[0-9]+ bats tests' README.md 2>/dev/null | head -1 | grep -oE '[0-9]+' || true)
if [ -n "$README_COUNT" ] && command -v bats >/dev/null 2>&1; then
  ACTUAL_COUNT=$(bats --count test/ 2>/dev/null || true)
  if [ -n "$ACTUAL_COUNT" ] && [ "$ACTUAL_COUNT" != "$README_COUNT" ]; then
    ISSUES="${ISSUES}\n- README says \"${README_COUNT} bats tests\" but there are actually ${ACTUAL_COUNT}"
  fi
fi

# 2. Check module count claims
README_MODULES=$(grep -oE '[0-9]+ NixOS modules' README.md 2>/dev/null | head -1 | grep -oE '[0-9]+' || true)
if [ -n "$README_MODULES" ] && [ -d modules ]; then
  ACTUAL_MODULES=$(find modules -maxdepth 1 -name '*.nix' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$ACTUAL_MODULES" != "$README_MODULES" ]; then
    ISSUES="${ISSUES}\n- README says \"${README_MODULES} NixOS modules\" but there are actually ${ACTUAL_MODULES}"
  fi
fi

# 3. Check that referenced just recipes exist
if [ -f justfile ] && command -v just >/dev/null 2>&1; then
  RECIPES=$(just --list --unsorted 2>/dev/null | awk '{print $1}' | grep -v '^Available' || true)
  while IFS= read -r recipe; do
    if ! echo "$RECIPES" | grep -qx "$recipe" 2>/dev/null; then
      # Check submodule recipes (just ssh claude -> ssh recipe with arg)
      MOD=$(echo "$recipe" | cut -d- -f1)
      if ! echo "$RECIPES" | grep -q "^${MOD}$" 2>/dev/null; then
        ISSUES="${ISSUES}\n- README references \`just ${recipe}\` but no such recipe exists"
      fi
    fi
  done < <(grep -oE 'just [a-z][-a-z]*' README.md 2>/dev/null | sed 's/^just //' | sort -u)
fi

[ -z "$ISSUES" ] && exit 0

echo "README_DRIFT: The commit introduced inconsistencies between README.md and the project:"
echo -e "${ISSUES}"
echo ""
echo "Please update README.md to match the current state, then create a follow-up commit."
echo "Do NOT amend the previous commit -- always create a new follow-up commit."
