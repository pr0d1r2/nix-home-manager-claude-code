#!/bin/bash
# Coverage checker: Ruby files -> RSpec specs
# Only active in Ruby projects (Gemfile present).

CHANGED="$1"

[ -f Gemfile ] || exit 0

UNCOVERED=""
for f in $(echo "$CHANGED" | grep '\.rb$' | grep -v '_spec\.rb$' | grep -v 'spec/' || true); do
    [ -f "$f" ] || continue
    spec_path="spec/$(echo "$f" | sed 's|^app/||; s|^lib/||; s|\.rb$|_spec.rb|')"
    [ -f "$spec_path" ] && continue
    UNCOVERED="$UNCOVERED $f"
done

[ -z "$UNCOVERED" ] && exit 0

echo "UNCOVERED_RUBY: The commit includes Ruby files without spec coverage:"
echo "${UNCOVERED}"
echo ""
echo "Please run /cover-rb to generate specs for these files, then create a follow-up commit."
echo "Do NOT amend the previous commit -- always create a new follow-up commit."
