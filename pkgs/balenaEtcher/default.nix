{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  versionCheckHook,
  xcbuild,
  writeShellScript
}:

stdenvNoCC.mkDerivation (finalAttrs:{
  pname = "balenaEtcher";
  version = "2.1.2";

  src = fetchurl {
    url = "https://github.com/balena-io/etcher/releases/download/v${finalAttrs.version}/balenaEtcher-${finalAttrs.version}-arm64.dmg";
    sha256 = "sha256-sqXbFtmCU+H9dGekzUZwA8Umop4tSYKCx0dm8FHBlgY=";
  };

  buildInputs = [ undmg ];

  sourceRoot = ".";
  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv balenaEtcher.app $out/Applications
    '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/balenaEtcher.app/Contents/Info.plist"
  ];
  doInstallCheck = true;

  meta = with lib; {
    description = "balenaEtcher";
    license = licenses.asl20;
    platforms = ["aarch64-darwin"];
  };
}
)