Generate RSpec test coverage for uncovered Ruby files.

## Process

1. **Find uncovered Ruby files** — scan for `.rb` files that lack corresponding specs in `spec/`
   - A file `app/services/foo.rb` is covered if `spec/services/foo_spec.rb` exists
   - A file `lib/bar.rb` is covered if `spec/lib/bar_spec.rb` exists
   - A file `scripts/baz.rb` is covered if `spec/scripts/baz_spec.rb` exists
   - If called with a specific file argument, only cover that file
2. **For each uncovered file**, create an RSpec test:
   - Mirror the source directory structure under `spec/`
   - Use the project's existing spec helper (`rails_helper` for Rails apps, `spec_helper` otherwise)
   - Test the public interface: public methods, class methods, validations
   - For shell script wrappers (`.sh` files in Ruby projects), use `Open3.capture3` to test
   - Follow existing spec patterns in the project
3. **Verify** tests pass: `rspec spec/<new-spec>.rb`

## Rules

- Only generate specs for files that don't already have coverage
- Follow existing RSpec conventions in the project (check for `let`, `shared_examples`, factory usage)
- Use FactoryBot if the project uses it (check for `spec/factories/`)
- Do NOT modify the source files — only create spec files
- If called as a sub-skill from `/extract-justfile-scripts-ruby`, only cover the newly extracted scripts
- For shell scripts in Ruby projects, generate specs using `Open3`:

## Example output

For `scripts/db/migrate.sh` in a Ruby project:

```ruby
# frozen_string_literal: true

require "open3"

RSpec.describe "scripts/db/migrate.sh" do
  let(:script) { File.expand_path("../../../scripts/db/migrate.sh", __dir__) }

  it "exists and is executable" do
    expect(File).to exist(script)
    expect(File).to be_executable(script)
  end

  it "has proper shebang" do
    first_line = File.readlines(script).first
    expect(first_line).to match(%r{#!/usr/bin/env bash})
  end

  it "uses strict mode" do
    content = File.read(script)
    expect(content).to include("set -euo pipefail")
  end
end
```

For `app/services/import_processor.rb`:

```ruby
# frozen_string_literal: true

require "rails_helper"

RSpec.describe ImportProcessor do
  describe "#call" do
    # Test public interface based on actual implementation
  end
end
```
