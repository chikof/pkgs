{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  maintainers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "kuna";
  # REA verifies against exactly this version
  version = "1.833";

  src = fetchurl {
    url = "https://github.com/Noelo-Lab/kuna/releases/download/v${finalAttrs.version}/kuna-v${finalAttrs.version}-linux-x86_64.tar.gz";
    hash = "sha256-6fBH+1qTkl7ebYad8iwmwcDO2QdkrOdGeukPiAYl1TA=";
  };

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib];

  installPhase = ''
    runHook preInstall
    install -Dm755 kuna $out/bin/kuna
    runHook postInstall
  '';

  meta = {
    description = "Kuna decompiler frontend, prebuilt binary";
    homepage = "https://github.com/Noelo-Lab/kuna";
    license = lib.licenses.asl20;
    maintainers = [maintainers.chiko];
    mainProgram = "kuna";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
