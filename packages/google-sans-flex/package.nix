{
  lib,
  stdenvNoCC,
  fetchurl,
  maintainers,
}: let
  rev = "bd8f81ddb5c74d5c8897b36ad88b440266245103";
  base = "https://raw.githubusercontent.com/google/fonts/${rev}/ofl/googlesansflex";
in
  stdenvNoCC.mkDerivation {
    pname = "google-sans-flex";
    version = "0-unstable-2026-10-09";

    srcs = [
      (fetchurl {
        # brackets are illegal in store path names
        name = "GoogleSansFlex.ttf";
        url = "${base}/GoogleSansFlex%5BROND%2Copsz%2Cslnt%2Cwdth%2Cwght%5D.ttf";
        hash = "sha256-qax3B5iFfV6KxZPO1Csi5Ap8CM7Jgxn5Kw7Mwng6d7o=";
      })
      (fetchurl {
        name = "OFL.txt";
        url = "${base}/OFL.txt";
        hash = "sha256-/BPWn2PjbShLbjg9TRRj2K1ATwqgZeV8+WElLVEGMTc=";
      })
    ];

    dontUnpack = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      for s in $srcs; do
        case $s in
          *GoogleSansFlex.ttf) install -Dm444 $s $out/share/fonts/truetype/GoogleSansFlex.ttf ;;
          *OFL.txt) install -Dm444 $s $out/share/licenses/google-sans-flex/OFL.txt ;;
        esac
      done
      runHook postInstall
    '';

    meta = {
      description = "Google Sans Flex variable font (ROND, opsz, slnt, wdth, wght axes)";
      homepage = "https://github.com/google/fonts/tree/main/ofl/googlesansflex";
      license = lib.licenses.ofl;
      maintainers = [maintainers.chiko];
      platforms = lib.platforms.all;
    };
  }
