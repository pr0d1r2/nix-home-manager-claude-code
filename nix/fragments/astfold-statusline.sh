#!/usr/bin/env bash
if ! @fast@ --help >/dev/null 2>&1; then
    exit 0
fi
if find . -maxdepth 3 -name '*.rb' -print -quit 2>/dev/null | grep -q .; then
    printf '\033[38;5;82m[ASTFOLD]\033[0m'
fi
