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
          sha256 = "0a87efaebfa86699e890175b40741be984520eb9e6d90136271774d13e217023";
        };
        aarch64-linux = {
          suffix = "arm64";
          sha256 = "00114206a6202cfb49dca2d8dd6faa3cc32db62eb1d2070a56d47b8bac27cf5b";
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
          version = "1.1.374";

          src = pkgs.fetchurl {
            url = "https://github.com/buxjr311/melia-app/releases/download/v${version}/${pname}_${version}_${arch.suffix}.AppImage";
            inherit (arch) sha256;
          };

          appImageContent = pkgs.appimageTools.extract { inherit pname version src; };

          desktopItem = pkgs.makeDesktopItem {
            name = pname;
            exec = "${pname} %U";
            icon = "melia";
            type = "Application";
            desktopName = "Melia";
            genericName = "Email Client";
            comment = "The modern email client for Linux";
            categories = [
              "Network"
              "Email"
            ];
            mimeTypes = [
              "message/rfc822"
              "x-scheme-handler/mailto"
              "x-scheme-handler/melia"
            ];
          };

          package = pkgs.appimageTools.wrapType2 {
            inherit pname version src;

            extraPkgs = pkgs: [
              pkgs.libappimage
            ];

            meta = {
              description = "The modern email client for Linux";
              homepage = "https://melia.buxjr.com/";
              downloadPage = "https://melia.buxjr.com/download";
              # license = pkgs.lib.licenses.unfree;
              platforms = systems;
            };

            extraInstallCommands = ''
              mkdir -p $out/share/applications/
              mkdir -p $out/share/icons/hicolor/512x512/apps/
              install -m 444 -D ${appImageContent}/melia.png "$out/share/icons/hicolor/512x512/apps/melia.png"
              install -m 444 -D ${desktopItem}/share/applications/*.desktop $out/share/applications/
            '';
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
