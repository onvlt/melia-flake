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
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          package = import ./default.nix { inherit pkgs system; };
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
