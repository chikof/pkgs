{
  lib,
  appimageTools,
  fetchurl,
  mpv,
  maintainers,
}: let
  pname = "seanime-denshi";
  version = "3.10.4";
  src = fetchurl {
    url = "https://github.com/5rahim/seanime/releases/download/v${version}/seanime-denshi-${version}_Linux_x86_64.AppImage";
    hash = "sha256-vB07WwRbG+E3j0UBr8Q2vygsBS1fslRROt3y469wFPU=";
  };
  contents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

    passthru.updateArgs = ["--url=https://github.com/5rahim/seanime"];

    # seanime shells out to mpv for playback
    extraPkgs = _: [mpv];

    extraInstallCommands = ''
      install -Dm444 ${contents}/seanime-denshi.desktop $out/share/applications/seanime-denshi.desktop
      substituteInPlace $out/share/applications/seanime-denshi.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=${pname}'
      cp -r ${contents}/usr/share/icons $out/share/icons
    '';

    meta = {
      description = "Desktop app (Electron) for Seanime, a media server for anime and manga";
      homepage = "https://seanime.app";
      license = lib.licenses.gpl3Only;
      maintainers = [maintainers.chiko];
      mainProgram = pname;
      platforms = ["x86_64-linux"];
    };
  }
