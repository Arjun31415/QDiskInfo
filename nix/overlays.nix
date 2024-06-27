{
  self,
  lib,
  inputs,
}: let
  mkDate = longDate: (lib.concatStringsSep "-" [
    (builtins.substring 0 4 longDate)
    (builtins.substring 4 2 longDate)
    (builtins.substring 6 2 longDate)
  ]);
in {
  # Contains what a user is most likely to care about:
  # Hyprland itself, XDPH and the Share Picker.
  default = lib.composeManyExtensions (with self.overlays; [
    QDiskInfo-package
  ]);

  # Packages for variations of Hyprland, dependencies included.
  QDiskInfo-package = lib.composeManyExtensions [
    (final: prev: let
      date = mkDate (self.lastModifiedDate or "19700101");
    in {
      QDiskInfo = final.qt6Packages.callPackage ./default.nix {
        stdenv = final.gcc13Stdenv;
        version = "date=${date}_${self.shortRev or "dirty"}";
      };
    })
  ];
}
