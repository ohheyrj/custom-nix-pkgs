{ lib
, stdenvNoCC
, fetchurl
, undmg
, versionCheckHook
, xcbuild
, writeShellScript
}:

let
  version = "2.1.2";

  # Choose the correct architecture-specific binary
  src = fetchurl {
    url = "https://github.com/balena-io/etcher/releases/download/v${version}/balenaEtcher-${version}-${archSuffix}.dmg";
    sha256 = if stdenvNoCC.system == "aarch64-darwin"
      then "sha256-sqXbFtmCU+H9dGekzUZwA8Umop4tSYKCx0dm8FHBlgY="
      else "sha256-UeeTKDqxjOBvjdDComO0BbV4w/+f49sz9exk0z6uO2E=";
  };

  archSuffix = if stdenvNoCC.system == "aarch64-darwin"
    then "arm64"
    else "x64";
in

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "balenaEtcher";
  inherit version src;

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
    homepage = "https://github.com/balena-io/etcher";
    changelog = "https://github.com/balena-io/etcher/blob/master/CHANGELOG.md";
    description = "Flash OS images to SD cards & USB drives, safely and easily.";
    license = licenses.asl20;
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    maintainers = [ maintainers.ohheyrj ];
  };
})
