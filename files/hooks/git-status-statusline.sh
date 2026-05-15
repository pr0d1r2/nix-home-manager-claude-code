#!/usr/bin/env bash
# runtimeInputs: [ git, coreutils ]
git_dir=$(git rev-parse --git-dir 2>/dev/null) || exit 0

if branch=$(git symbolic-ref --short HEAD 2>/dev/null); then
    :
else
    branch=$(git rev-parse --short HEAD 2>/dev/null) || exit 0
fi

dirty=""
git diff --quiet HEAD 2>/dev/null || dirty="*"

ahead_behind=""
cache="$git_dir/claude-statusline-cache"
if [ -f "$cache" ]; then
    read -r ts data <"$cache"
    now=$(date +%s)
    if [ "$((now - ts))" -lt 10 ]; then
        ahead_behind="$data"
    fi
fi

if [ ! -f "$cache" ] || [ "$(($(date +%s) - ts))" -ge 5 ]; then
    (
        upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null) || {
            printf '%s' "$(date +%s)" >"$cache"
            exit 0
        }
        counts=$(git rev-list --left-right --count HEAD..."$upstream" 2>/dev/null)
        ahead=$(printf '%s' "$counts" | cut -f1)
        behind=$(printf '%s' "$counts" | cut -f2)
        result=""
        [ "$ahead" -gt 0 ] 2>/dev/null && result="+${ahead}"
        [ "$behind" -gt 0 ] 2>/dev/null && result="${result:+$result}-${behind}"
        printf '%s %s' "$(date +%s)" "$result" >"$cache"
    ) &
fi

printf '\033[38;5;2m(git:%s%s%s)\033[0m' "$branch" "${dirty}" "${ahead_behind:+ $ahead_behind}"
