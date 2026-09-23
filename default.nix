{
  pkgs,
}:
let
  archMap = {
    x86_64-linux = {
      suffix = "x64";
      sha256 = "f207e17a2a9b8b6211ea8cfb06d2135cf4c78d49cd34cbb20b624a158b96dcb2";
    };
    aarch64-linux = {
      suffix = "arm64";
      sha256 = "0a855f50e243fac9980ca1522a0640624aaeb3d206fc74db597ce224d0a363cc";
    };
  };

  arch = archMap.${pkgs.stdenv.hostPlatform.system};
  pname = "melia";
  version = "1.1.389";

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
