{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  makeWrapper,
  patchelf,
  alsa-plugins,
  alsa-lib,
  dbus,
  fontconfig,
  freetype,
  glib-networking,
  gst_all_1,
  libxcb,
  libxcursor,
  libxi,
  libx11,
  libxkbcommon,
  pipewire,
  sqlite,
  symlinkJoin,
  vulkan-loader,
  wayland,
  webkitgtk_4_1,
  maintainers,
}: let
  runtimeLibraries = [
    vulkan-loader
    wayland
    libxkbcommon
    libxcb
    libx11
    libxcursor
    libxi
    fontconfig
    freetype
    alsa-lib
    dbus
    sqlite
    webkitgtk_4_1
    glib-networking
  ];

  # webkitgtk plays media through GStreamer and aborts its web process without an audio sink;
  # autoaudiosink lives in -good, which the webkitgtk closure does not carry
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" (with gst_all_1; [
    gstreamer
    gst-plugins-base
    gst-plugins-good
  ]);

  alsaPluginDir = symlinkJoin {
    name = "sonora-alsa-plugins";
    paths = [
      "${pipewire}/lib/alsa-lib"
      "${alsa-plugins}/lib/alsa-lib"
    ];
  };
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "sonora";
    version = "0.47.0";

    # desktop entry, icons and licences; the release asset is only the binary
    src = fetchFromGitHub {
      owner = "sonorahq";
      repo = "sonora";
      tag = "v${finalAttrs.version}";
      hash = "sha256-0UC2xRaxU2N8jwLelxSaWdX+vRn8Oa9UYhERTw+R6fw=";
    };

    passthru.binary = fetchurl {
      url = "https://github.com/sonorahq/sonora/releases/download/v${finalAttrs.version}/sonora-v${finalAttrs.version}-x86_64-unknown-linux-gnu";
      hash = "sha256-kIbkTKG/vChrlqjHDo768Sk1QD001ufIttBxR864qlM=";
    };

    passthru.updateArgs = ["--subpackage" "binary"];

    nativeBuildInputs = [makeWrapper patchelf];

    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 ${finalAttrs.passthru.binary} $out/bin/sonora
      install -Dm444 assets/linux/sonora.desktop $out/share/applications/sonora.desktop
      install -Dm444 assets/linux/sonora.svg $out/share/icons/hicolor/scalable/apps/sonora.svg
      for icon in assets/linux/icons/hicolor/*/apps/sonora.png; do
        size="$(basename "$(dirname "$(dirname "$icon")")")"
        install -Dm444 "$icon" "$out/share/icons/hicolor/$size/apps/sonora.png"
      done
      install -Dm444 COPYING $out/share/licenses/sonora/LICENSE
      install -Dm444 THIRD-PARTY.md $out/share/licenses/sonora/THIRD-PARTY.md

      runHook postInstall
    '';

    # webkitgtk and the GPU/audio stacks are dlopen'd, so they never show up as link-time
    # dependencies and autoPatchelfHook would not find them
    postFixup = ''
      patchelf \
        --set-interpreter "${stdenv.cc.bintools.dynamicLinker}" \
        --add-rpath "${lib.makeLibraryPath (runtimeLibraries ++ [stdenv.cc.cc.lib])}" \
        "$out/bin/sonora"
      wrapProgram "$out/bin/sonora" \
        --set ALSA_PLUGIN_DIR ${alsaPluginDir} \
        --prefix GIO_EXTRA_MODULES : ${glib-networking}/lib/gio/modules \
        --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${gstPluginPath}
    '';

    meta = {
      description = "Native, familiar music streaming client";
      homepage = "https://sonorahq.org";
      changelog = "https://github.com/sonorahq/sonora/blob/v${finalAttrs.version}/CHANGELOG.md";
      license = with lib.licenses; [
        gpl3Plus
        ofl
        isc
      ];
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      maintainers = [maintainers.chiko];
      mainProgram = "sonora";
      platforms = ["x86_64-linux"];
    };
  })
