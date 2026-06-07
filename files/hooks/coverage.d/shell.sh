#!/bin/bash
# Coverage checker: shell scripts -> bats tests
# Outputs uncovered files and suggested skill, or nothing if all covered.

CHANGED="$1"

UNCOVERED=""
for f in $(echo "$CHANGED" | grep '\.sh$' || true); do
  [ -f "$f" ] || continue
  base=$(basename "$f" .sh)
  dir=$(dirname "$f")
  # Check multiple naming conventions:
  #   scripts/iso/build.sh -> test/build.bats, test/iso/build.bats, test/iso.bats
  #   scripts/otel/configure.sh -> test/otel-configure.bats, test/otel.bats
  parent=$(basename "$dir")
  if [ -f "test/${base}.bats" ] || [ -f "test/${dir}/${base}.bats" ] ||
    [ -f "test/${parent}.bats" ] || [ -f "test/${parent}-${base}.bats" ]; then
    continue
  fi
  # Also check if any test file references this script
  if grep -rql "$(basename "$f")" test/*.bats 2>/dev/null; then
    continue
  fi
  # For Ruby projects, check spec/ too
  if [ -f Gemfile ]; then
    if [ -f "spec/scripts/${base}_spec.rb" ] || [ -f "spec/scripts/${dir}/${base}_spec.rb" ]; then
      continue
    fi
  fi
  UNCOVERED="$UNCOVERED $f"
done

[ -z "$UNCOVERED" ] && exit 0

if [ -f Gemfile ]; then
  SKILL="/cover-rb"
else
  SKILL="/cover-sh"
fi

echo "UNCOVERED_SHELL: The commit includes shell scripts without test coverage:"
echo "${UNCOVERED}"
echo ""
echo "Please run ${SKILL} to generate tests for these files, then create a follow-up commit."
echo "Do NOT amend the previous commit -- always create a new follow-up commit."
