{ stdenvNoCC, fetchurl, _7zz, cpio, xar, xcbuild, versionCheckHook, writeShellScript, lib, undmg }:

let
  version = "4.8.13";
  versionNoDots = builtins.replaceStrings [ "." ] [ "" ] version;
  mapInstallVersion = "4.3.6";
  mapManagerVersion = "3.1.3";
in

stdenvNoCC.mkDerivation {
  pname = "garmin-basecamp";
  inherit version;

  src = fetchurl {
    url = "https://download.garmin.com/software/BaseCampforMac_${versionNoDots}.dmg";
    sha256 = "sha256-5M209u+JpwnRl+AnOgb5lbtLNUJTjw8+R0O/yFznTgs=";
  };

  buildInputs = [
    _7zz
    cpio
    xar
    undmg
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    ls -al
    7zz x "Install BaseCamp.pkg" -o$TMPDIR
    cd $TMPDIR
    ls -al
    cat garminBaseCamp.pkg/Payload | gunzip -dc | cpio -i
    cat garminMapInstall.pkg/Payload | gunzip -dc | cpio -i
    cat garminMapManager.pkg/Payload | gunzip -dc | cpio -i
    mkdir -p $out/Applications
    mv *.app $out/Applications
    runHook postInstall
    '';
  
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/Garmin BaseCamp.app/Contents/Info.plist"
  ];
  doInstallCheck = true;
  meta = with lib; {
    description = "Garmin BaseCamp";
    license = licenses.unfree;
    platforms = platforms.darwin;
  };
}