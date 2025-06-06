{
  stdenvNoCC,
  fetchurl,
  undmg,
  lib
}:

let
  version = "2.5.3";
in

stdenvNoCC.mkDerivation {
  pname = "chatterino";
  inherit version;

  src = fetchurl {
    url = "https://chatterino.fra1.digitaloceanspaces.com/bin/${version}/Chatterino.dmg";
    hash = "sha256-pTAw2Ko1fcYxWhQK9j0odQPn28I1Lw2CHLs21KCbo7g=";
  };

  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  dontFixup = true;

  buildInputs = [ undmg ];

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall

    mkdir -p $out/Applications
    mv Chatterino.app $out/Applications
    '';

    meta = with lib; {
      homepage = "https://chatterino.com";
      changelog = "https://github.com/Chatterino/chatterino2/blob/master/CHANGELOG.md";
      maintainers = [ maintainers.ohheyrj ];
      description = "Chat client for Twitch";
      license = licenses.mit;
      platforms = platforms.darwin;
    };
}
