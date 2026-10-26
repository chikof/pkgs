{
  lib,
  fetchurl,
  stdenvNoCC,
  maintainers,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jadx-headless-mcp";
  # REA pins the JAR to exactly this version
  version = "0.7.1";

  src = fetchurl {
    url = "https://github.com/1013503897/jadx-headless-mcp/releases/download/v${finalAttrs.version}/jadx-headless-mcp-${finalAttrs.version}-all.jar";
    hash = "sha256-bl6s9QC2QpK/tzxJeXwZWPbuRGRuQ+hoA5rn/rVz/3U=";
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 $src $out/share/java/jadx-headless-mcp.jar
    runHook postInstall
  '';

  meta = {
    description = "Headless jadx MCP server fat JAR used by REA";
    homepage = "https://github.com/1013503897/jadx-headless-mcp";
    license = lib.licenses.asl20;
    maintainers = [maintainers.chiko];
    platforms = lib.platforms.all;
    sourceProvenance = [lib.sourceTypes.binaryBytecode];
  };
})
