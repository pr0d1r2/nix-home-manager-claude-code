{
  pkgs,
  cavemem,
}:
pkgs.runCommand "cavemem-gc-check"
  {
    nativeBuildInputs = [ pkgs.bash ];
    src = ./check-cavemem-gc.sh;
  }
  ''
    bash $src ${cavemem}
    touch $out
  ''
