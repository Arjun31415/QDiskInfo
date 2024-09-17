{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # <https://github.com/nix-systems/nix-systems>
    systems.url = "github:nix-systems/default-linux";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    systems,
    ...
  }: let
    inherit (nixpkgs) lib;
    eachSystem = lib.genAttrs (import systems);
    pkgsFor = eachSystem (system:
      import nixpkgs {
        localSystem = system;
        overlays = [self.overlays.QDiskInfo-package];
      });
  in {
    overlays = import ./nix/overlays.nix {inherit self lib inputs;};

    packages = eachSystem (system: {
      default = self.packages.${system}.QDiskInfo;
      inherit
        (pkgsFor.${system})
        QDiskInfo
        ;
    });

    devShells = eachSystem (system: {
      default = pkgsFor.${system}.mkShell {
        name = "QDiskInfo-shell";
        # nativeBuildInputs = with pkgsFor.${system}; [];
        # hardeningDisable = ["fortify"];
        inputsFrom = [pkgsFor.${system}.QDiskInfo];
        packages = with pkgsFor.${system}; [
          kdePackages.qttools
          qtcreator
        ];

      };
    });

    formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}

