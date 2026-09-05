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
          sha256 = "187glnyzhv6aigxpnicvbxv30jshp7ygwikkbaci5xpfb61w4sf1";
        };
        aarch64-linux = {
          suffix = "arm64";
          sha256 = "0mhb9xqzb0qpy46yh5wrrixw1zhdvnzknr0yrl9cf7qhp09jls64";
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
          version = "1.1.370";

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
