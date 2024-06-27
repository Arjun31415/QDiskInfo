{
  lib,
  stdenv,
  cmake,
  ninja,
  qtbase,
  qtsvg,
  qttools,
  wrapQtAppsHook,
  qtwayland,
  version,
  smartmontools,
}: let
  qtVersion = lib.versions.major qtbase.version;
in
  stdenv.mkDerivation {
    pname = "QDiskInfo";
    inherit version;

    src = lib.cleanSourceWith {
      filter = name: type: let
        baseName = baseNameOf (toString name);
      in
        ! (lib.hasSuffix ".nix" baseName);
      src = lib.cleanSource ../.;
    };
    nativeBuildInputs = [
      cmake
      ninja
      wrapQtAppsHook
      smartmontools
    ];

    buildInputs = [
      qtbase
      qtsvg
      qttools
      qtwayland
    ];

    qtWrapperArgs =  [
      "--prefix PATH : ${lib.makeBinPath [smartmontools]}"
    ];

    cmakeFlags = lib.optionals (qtVersion == "6") [
      "-DQT_VERSION_MAJOR=6"
    ];
  }
