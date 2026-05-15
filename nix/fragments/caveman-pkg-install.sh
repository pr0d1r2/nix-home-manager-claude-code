# shellcheck shell=bash
# $out is provided by the nix build sandbox
# shellcheck disable=SC2154
mkdir -p "$out/hooks" "$out/skills/caveman"
cp hooks/package.json hooks/caveman-config.js hooks/caveman-activate.js \
    hooks/caveman-mode-tracker.js "$out/hooks/"
cp hooks/caveman-statusline.sh "$out/hooks/"
chmod +x "$out/hooks/caveman-statusline.sh"
cp skills/caveman/SKILL.md "$out/skills/caveman/"
