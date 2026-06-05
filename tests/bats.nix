{
  pkgs,
  src,
}:
pkgs.runCommand "bats-tests"
  {
    nativeBuildInputs = with pkgs; [
      bash
      bats
      findutils
      git
      jq
      procps
    ];
    inherit src;
  }
  ''
    cp -r $src/* .
    chmod -R u+w .
    bats --recursive tests/unit/
    touch $out
  ''
