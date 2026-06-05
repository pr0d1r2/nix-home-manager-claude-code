{
  pkgs,
  claude-code,
}:
pkgs.runCommand "claude-code-binary-check"
  {
    nativeBuildInputs = [ pkgs.bash ];
    src = ./check-claude-code-binary.sh;
  }
  ''
    bash $src ${claude-code}
    touch $out
  ''
