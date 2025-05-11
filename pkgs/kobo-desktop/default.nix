{ pkgs ? import <nixpkgs> {} }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "kobo-desktop";
  version = "0-unstable-2025-05-11";

  src = pkgs.fetchurl {
    url = "https://cdn.kobo.com/downloads/desktop/kobodesktop/kobosetup.dmg";
    hash = "sha256-OHkhC1lPwgoPr3/629FLf8hSVZZhcuAHlREYx0CX7m8=";
  };

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  buildInputs = [ pkgs.undmg ];

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Kobo.app $out/Applications
    '';

    meta = with pkgs.lib; {
      description = "Kobo Desktop";
      license = licenses.unfree;
      platforms = platforms.darwin;
    };
}
