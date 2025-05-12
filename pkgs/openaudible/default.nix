{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  versionCheckHook,
  xcbuild,
  writeShellScript,
  _7zz
}:

stdenvNoCC.mkDerivation (finalAttrs:{
  pname = "OpenAudible";
  version = "4.5.3";

  src = fetchurl {
    url = "https://openaudible.org/latest/OpenAudible.dmg";
    sha256 = "sha256-AHr7uOwyPhWX8Qm0X1n/eGbP5MYcCe4+wSFQyPkR9w8=";
  };

  dontUnpack = true;

  buildInputs = [ _7zz ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    # Using 7zz and extracting only the OpenAudible.app due to /Applcation symbolink
    # link issue
    7zz x $src 'OpenAudible/OpenAudible.app' -o$TMPDIR

    mkdir -p $out/Applications
    mv $TMPDIR/OpenAudible/OpenAudible.app $out/Applications
  '';

  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = writeShellScript "version-check" ''
    ${xcbuild}/bin/PlistBuddy -c "Print :CFBundleShortVersionString" "$1"
  '';
  versionCheckProgramArg = [
    "${placeholder "out"}/Applications/OpenAudible.app/Contents/Info.plist"
  ];
  doInstallCheck = true;

  meta = with lib; {
    description = "OpenAudible";
    license = licenses.unfree;
    platforms = platforms.darwin;
  };
}
)