{
  fetchPnpmDeps,
  lib,
  makeWrapper,
  nodejs_24,
  node-gyp,
  pkg-config,
  pnpm_9,
  pnpmConfigHook,
  python3,
  sqlite,
  stdenv,
  maintainers,
  sources,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cavemem";
  inherit (sources.cavemem) version src;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_9;
    fetcherVersion = 3;
    hash = "sha256-xVdck9jTZPm3gf3kZ/KZI4bO0jkTfhZP5j41MlNAvlA=";
  };

  postPatch = ''
    echo "node-linker=hoisted" >> .npmrc
  '';

  nativeBuildInputs = [
    nodejs_24
    pnpm_9
    pnpmConfigHook
    makeWrapper
    python3
    pkg-config
    node-gyp
  ];

  buildInputs = [
    sqlite
  ];

  buildPhase = ''
    runHook preBuild
    pushd node_modules/better-sqlite3
    node-gyp rebuild --nodedir=${nodejs_24}/include/node
    popd
    pnpm --filter cavemem build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib/cavemem
    cp -r apps/cli/dist $out/lib/cavemem/
    cp apps/cli/package.json $out/lib/cavemem/
    cp -rL node_modules $out/lib/cavemem/
    mkdir -p $out/bin
    makeWrapper ${nodejs_24}/bin/node $out/bin/cavemem \
      --add-flags "$out/lib/cavemem/dist/index.js"
    runHook postInstall
  '';

  meta = with lib; {
    description = "Cross-agent persistent memory for AI coding assistants";
    homepage = "https://github.com/JuliusBrussee/cavemem";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [maintainers.chiko];
    mainProgram = "cavemem";
  };
})
