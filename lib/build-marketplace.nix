pkgs:
{
  name,
  src,
  subPlugins ? [ name ],
}:
pkgs.stdenvNoCC.mkDerivation {
  pname = "claude-code-marketplace-${name}";
  version = "0.0.0";
  inherit src;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';
  passthru = {
    marketplaceName = name;
    inherit subPlugins;
  };
}
