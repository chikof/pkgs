{
  lib,
  appimageTools,
  mpv,
  sources,
  maintainers,
}: let
  inherit (sources.seanime-denshi) pname version src;
  contents = appimageTools.extract {inherit pname version src;};
in
  appimageTools.wrapType2 {
    inherit pname version src;

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
