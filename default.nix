{
  pkgs,
}:
let
  archMap = {
    x86_64-linux = {
      suffix = "x64";
      sha256 = "d29471c6a2c1e700c7c9a46ecea59c40e7cd96cf68f87dc9104b3d656b87e186";
    };
    aarch64-linux = {
      suffix = "arm64";
      sha256 = "4767e6f4f72cf2e4463b47b840e9f2fb5a7be1876aaa6e4455b9d5d50b7a91f3";
    };
  };

  arch = archMap.${pkgs.stdenv.hostPlatform.system};
  pname = "melia";
  version = "1.1.400";

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
