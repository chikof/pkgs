{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  maintainers,
}:
# Upstream builds from source with zig + a prebuilt V8 archive + crane; the release binary is the cheap pin.
stdenv.mkDerivation rec {
  pname = "lightpanda";
  version = "1.0.4";

  src = fetchurl {
    url = "https://github.com/lightpanda-io/browser/releases/download/${version}/lightpanda-x86_64-linux";
    hash = "sha256-fSJlESmQEgOr25XGT0kGnEnoj1IR9NjExoKMEjxK2rQ=";
  };

  dontUnpack = true;
  nativeBuildInputs = [autoPatchelfHook];
  buildInputs = [stdenv.cc.cc.lib];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/lightpanda
    runHook postInstall
  '';

  meta = {
    description = "Headless browser built from scratch for AI agents and automation (CDP server)";
    homepage = "https://github.com/lightpanda-io/browser";
    license = lib.licenses.agpl3Only;
    mainProgram = "lightpanda";
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
    maintainers = [maintainers.chiko];
  };
}
