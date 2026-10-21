{
  pkgs,
}:
let
  archMap = {
    x86_64-linux = {
      suffix = "x64";
      sha256 = "fadf1e7a91576c4698b81669d56c9cea38fd69a805abe24b8e177790c6d2022e";
    };
    aarch64-linux = {
      suffix = "arm64";
      sha256 = "1fb4f500e5f7c7ca4bc20106c7c17929c4cd4c35e4526b5b637b1c3d553264a4";
    };
  };

  arch = archMap.${pkgs.stdenv.hostPlatform.system};
  pname = "melia";
  version = "1.1.415";

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
in

pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraPkgs = pkgs: [
    pkgs.libappimage
  ];

  meta = {
    description = "The modern email client for Linux";
    homepage = "https://melia.buxjr.com/";
    downloadPage = "https://melia.buxjr.com/download";
    license = pkgs.lib.licenses.unfree;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };

  extraInstallCommands = ''
    mkdir -p $out/share/applications/
    mkdir -p $out/share/icons/hicolor/512x512/apps/
    install -m 444 -D ${appImageContent}/melia.png "$out/share/icons/hicolor/512x512/apps/melia.png"
    install -m 444 -D ${desktopItem}/share/applications/*.desktop $out/share/applications/
  '';
}
