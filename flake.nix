{
  description = "Melia email client flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      archMap = {
        x86_64-linux = "x64";
        aarch64-linux = "arm64";
      };

      makePackage = system:
        let
          pkgs = import nixpkgs { inherit system; };
          appimageTools = pkgs.appimageTools;

          pname = "melia";
          version = "1.1.370";
          arch = archMap.${system};
          url = "https://github.com/buxjr311/melia-app/releases/download/v${version}/${pname}_${version}_${arch}.AppImage";
          sha256 = if system == "x86_64-linux" then "187glnyzhv6aigxpnicvbxv30jshp7ygwikkbaci5xpfb61w4sf1" else "0mhb9xqzb0qpy46yh5wrrixw1zhdvnzknr0yrl9cf7qhp09jls64";

        in
        appimageTools.wrapType2 {
          inherit pname version;
          src = pkgs.fetchurl {
            inherit url sha256;
          };
          extraPkgs = pkgs: [
            pkgs.libappimage
          ];
        };
    in
    {
      packages.x86_64-linux.melia = makePackage "x86_64-linux";
      packages.aarch64-linux.melia = makePackage "aarch64-linux";
    };
}