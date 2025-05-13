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
      homepage = "https://www.kobo.com/gb/en/p/desktop";
      maintainers = [ maintainers.ohheyrj ];
      description = "Kobo Desktop is a free app for Windows and Mac that lets you buy, read, and manage eBooks, as well as sync them with your Kobo eReader.";
      license = licenses.unfree;
      platforms = platforms.darwin;
    };
}
