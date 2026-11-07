{
  pkgs,
}:
let
  archMap = {
    x86_64-linux = {
      suffix = "x64";
      sha256 = "704fc7169f53ba958f6978c56f644e0b2d9dcd818838b584215f7bc9059aa675";
    };
    aarch64-linux = {
      suffix = "arm64";
      sha256 = "bb66116ce035816fc63a4fe92a7d72cfd95b4de95eef3d1e19c9e4bc7482d818";
    };
  };

  arch = archMap.${pkgs.stdenv.hostPlatform.system};
  pname = "melia";
  version = "1.1.423";

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
