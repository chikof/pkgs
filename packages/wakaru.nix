{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  maintainers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "wakaru";
  # REA accepts ^1.13.0 (verified with 1.14.0)
  version = "1.14.0";

  src = fetchurl {
    url = "https://github.com/pionxzh/wakaru/releases/download/v${finalAttrs.version}/wakaru-linux-x64.tar.gz";
    hash = "sha256-2w5iADRyMZWrQm6U0A1V29j9AQapKK2iVj8RAxltCfo=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib];

  installPhase = ''
    runHook preInstall
    install -Dm755 wakaru $out/bin/wakaru
    runHook postInstall
  '';

  meta = {
    description = "JavaScript decompiler and unminifier, prebuilt binary";
    homepage = "https://github.com/pionxzh/wakaru";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "wakaru";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
