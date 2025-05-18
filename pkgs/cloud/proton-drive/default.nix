{ lib
, stdenvNoCC
, fetchurl
, _7zz
, versionCheckHook
, xcbuild
, writeShellScript
}:

let
  version = "2.3.0";
in

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "proton-drive";
  inherit version;

  src = fetchurl {
      url = "https://proton.me/download/drive/macos/${version}/ProtonDrive-${version}.dmg";
      hash = "sha256-LDaV8G4q7uqD+4rPgSMhanPTj9uKWqQFNVsmwmS36Ls=";
    };

  buildInputs = [ _7zz ];
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    ls -al
    mkdir -p $out/Applications
    mv Proton\ Drive.app $out/Applications
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/Proton Drive.app/Contents/Info.plist"
  ];
  doInstallCheck = true;

  meta = with lib; {
    homepage = "https://proton.me/drive";
    description = "Proton Drive Mac Client";
    license = licenses.gpl3;
    platforms = platforms.darwin;
    maintainers = [ maintainers.ohheyrj ];
  };
})
