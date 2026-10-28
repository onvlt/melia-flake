{
  pkgs,
}:
let
  archMap = {
    x86_64-linux = {
      suffix = "x64";
      sha256 = "0432244034517db8af81b26255e345ec1b818e672549be675587d370d4947315";
    };
    aarch64-linux = {
      suffix = "arm64";
      sha256 = "1e61661266b77e05825166e6863b8619b4ce7d9a440ad0474680c2011f9d9494";
    };
  };

  arch = archMap.${pkgs.stdenv.hostPlatform.system};
  pname = "melia";
  version = "1.1.420";

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
