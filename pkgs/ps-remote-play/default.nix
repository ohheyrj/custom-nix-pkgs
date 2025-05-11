{ stdenvNoCC, fetchurl, _7zz, cpio, xar, xcbuild, versionCheckHook, writeShellScript, lib }:

stdenvNoCC.mkDerivation {
  pname = "ps-remote-play";
  version = "8.0.0";
  src = fetchurl {
    url = "https://remoteplay.dl.playstation.net/remoteplay/module/mac/RemotePlayInstaller.pkg";
    sha256 = "sha256-+iyK9RcaFLqVlRZaHMGxxlMpxkGgCuP+zzW12xOjms4=";
  };
  buildInputs = [
    _7zz
    cpio
    xar
  ];
  sourceRoot = ".";
  unpackPhase = ''
    runHook preUnpack
    7zz x $src -o$TMPDIR
    cd $TMPDIR
    cat RemotePlay.pkg/Payload | gunzip -dc | cpio -i
    runHook postUnpack
    '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv RemotePlay.app $out/Applications
    runHook postInstall
    '';
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/RemotePlay.app/Contents/Info.plist"
  ];
  doInstallCheck = true;
  meta = with lib; {
    description = "PS Remote Play";
    license = licenses.unfree;
    platforms = platforms.darwin;
  };
}