#!/usr/bin/env bats

setup() {
    TEST_DIR="$(mktemp -d)"
    cd "$TEST_DIR" || exit 1
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "skips when no Gemfile" {
    run bash "$OLDPWD/files/hooks/coverage.d/ruby.sh" "app/models/user.rb"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "flags .rb file without spec" {
    touch Gemfile
    mkdir -p app/models
    echo 'class User; end' >app/models/user.rb

    run bash "$OLDPWD/files/hooks/coverage.d/ruby.sh" "app/models/user.rb"
    [ "$status" -eq 0 ]
    [[ "$output" == *"UNCOVERED_RUBY"* ]]
    [[ "$output" == *"app/models/user.rb"* ]]
}

@test "passes when spec exists" {
    touch Gemfile
    mkdir -p app/models spec/models
    echo 'class User; end' >app/models/user.rb
    echo 'describe User' >spec/models/user_spec.rb

    run bash "$OLDPWD/files/hooks/coverage.d/ruby.sh" "app/models/user.rb"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "ignores _spec.rb files" {
    touch Gemfile
    mkdir -p spec/models
    echo 'describe User' >spec/models/user_spec.rb

    run bash "$OLDPWD/files/hooks/coverage.d/ruby.sh" "spec/models/user_spec.rb"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "ignores files in spec/ directory" {
    touch Gemfile
    mkdir -p spec/support
    echo 'module Helper; end' >spec/support/helper.rb

    run bash "$OLDPWD/files/hooks/coverage.d/ruby.sh" "spec/support/helper.rb"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}

@test "ignores deleted .rb files" {
    touch Gemfile

    run bash "$OLDPWD/files/hooks/coverage.d/ruby.sh" "app/models/gone.rb"
    [ "$status" -eq 0 ]
    [ -z "$output" ]
}
