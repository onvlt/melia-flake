{
  description = "Melia email client flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      archMap = {
        x86_64-linux = {
          suffix = "x64";
          sha256 = "ee7c69cf1865eef4c7a95ad14ac5df430fa3d71ddd5ec7c38c186ade93a4359e";
        };
        aarch64-linux = {
          suffix = "arm64";
          sha256 = "3c315f04ec56881de2e32a8d38c0ecd62d7ea6a058f9eb3f52f198788c126051";
        };
      };
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          arch = archMap.${system};
          pname = "melia";
          version = "1.1.371";

          src = pkgs.fetchurl {
            url = "https://github.com/buxjr311/melia-app/releases/download/v${version}/${pname}_${version}_${arch.suffix}.AppImage";
            inherit (arch) sha256;
          };

          package = pkgs.appimageTools.wrapType2 {
            inherit pname version src;

            extraPkgs = pkgs: [
              pkgs.libappimage
            ];
          };
        in
        {
          default = package;
          melia = package;
        }
      );

      overlays.default = final: prev: {
        melia = self.packages.${prev.stdenv.hostPlatform.system}.default;
      };
    };
}
