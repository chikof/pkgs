{
  lib,
  rustPlatform,
  fetchFromGitHub,
  makeDesktopItem,
  copyDesktopItems,
  appimage-run,
  libnotify,
  runtimeShell,
  maintainers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sunbird";
  version = "0.1.0-unstable-2026-11-25";

  src = fetchFromGitHub {
    owner = "sunbird-tools";
    repo = "sunbird";
    rev = "10f30b3390d52d12e23e28ead49dcca8e2df32ef";
    hash = "sha256-nNECHS6aDWOgSaoyaCl/x6PkQiN2RPpmMrgB42BX9dg=";
  };

  cargoHash = "sha256-zvsr8LAnZhCTQlgNPgoENyDXtcV8hKPu9s8Ry888xbE=";
  cargoBuildFlags = ["-p" "phoenix-loader"];

  # workspace tests cover the Android patcher and UI codecs, not the Linux loader
  doCheck = false;

  # scanning for hooks leaves all 422 MB of Discord's binary resident; https://github.com/chikof/sunbird/tree/hook/release-scanned-pages
  patches = [./release-scanned-pages.patch];

  # the runtime string-compares this with the site's date-based version; `nix-` sorts after every date,
  # so it never asks for a restart over a loader update that only a package bump delivers
  postPatch = ''
    substituteInPlace crates/runtime/build.rs \
      --replace-fail '"0".to_owned()' '"nix-${finalAttrs.version}".to_owned()'
  '';

  # the loader runs inside Discord's process: keep SQLite bundled as upstream ships it, not the system one cargoSetupHook picks
  preBuild = ''
    export LIBSQLITE3_SYS_USE_PKG_CONFIG=0
  '';

  nativeBuildInputs = [copyDesktopItems];

  postInstall = ''
    mkdir -p $out/bin
    substitute ${./sunbird.sh} $out/bin/sunbird \
      --replace-fail @runtimeShell@ ${runtimeShell} \
      --replace-fail @loader@ $out/lib/libphoenix.so \
      --replace-fail @appimageRun@ ${lib.getExe finalAttrs.passthru.runner} \
      --replace-fail @notifySend@ ${lib.getExe' libnotify "notify-send"}
    chmod +x $out/bin/sunbird
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "sunbird";
      desktopName = "Sunbird";
      comment = "Discord Phoenix with Sunbird";
      exec = "sunbird %U";
      # Discord installs this icon into ~/.local/share/icons on its first run
      icon = "com.discord.libdiscord";
      categories = ["Network" "InstantMessaging"];
      mimeTypes = ["x-scheme-handler/discord"];
      startupWMClass = "com.discord.libdiscord";
    })
  ];

  # what the loader (tray, notifications) and Discord (VA-API) look for and stock appimage-run lacks
  passthru.runner = appimage-run.override {
    extraPkgs = p: [
      # the tray script runs `python3 -I`, which ignores PYTHONPATH
      (p.python3.withPackages (ps: [ps.pygobject3]))
      p.gobject-introspection
      p.libayatana-appindicator
      p.libnotify
      p.libva
    ];
  };

  passthru.updateArgs = ["--version=branch"];

  meta = {
    description = "Plugin runtime and unlock for Discord Phoenix, preloaded into your own AppImage";
    longDescription = ''
      Discord Phoenix is not redistributable: download its AppImage yourself.
      `sunbird` uses `$SUNBIRD_APPIMAGE`, or else the newest `*discord*.AppImage`
      in the current directory, `~/Applications`, `~/Downloads` or `~/Desktop`,
      or else the AppImage Discord last ran from.
      Set `SUNBIRD_GATE_ONLY=1` to open only the access gate without the plugin runtime.
    '';
    homepage = "https://github.com/sunbird-tools/sunbird";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "sunbird";
    platforms = ["x86_64-linux"];
  };
})
