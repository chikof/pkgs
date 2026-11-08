{
  fetchFromGitHub,
  git,
  lib,
  nodejs,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  stdenv,
  discord,
  discord-ptb,
  discord-canary,
  discord-development,
  maintainers,
  buildWebExtension ? false,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "equicord";
  version = "0-unstable-2026-11-07";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    rev = "200dba124066146a8f043fde7fc8b05e3dc5e68e";
    hash = "sha256-R31S8NVVYECxKBTGyyHUuf9Drc4q8pQALxKElwJxU1k=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-+W+itQv+BsB24B+wxKGAXfUikeJxqkDyVSZCXTsE8Ro=";
  };

  nativeBuildInputs = [
    git
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  env = {
    EQUICORD_REMOTE = "${finalAttrs.src.owner}/${finalAttrs.src.repo}";
    EQUICORD_HASH = "${finalAttrs.src.rev}";
  };

  buildPhase = ''
    runHook preBuild

    pnpm run ${
      if buildWebExtension
      then "buildWeb"
      else "build"
    } \
      -- --standalone --disable-updater

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist/${lib.optionalString buildWebExtension "chromium-unpacked/"} $out

    runHook postInstall
  '';

  passthru = {
    updateArgs = ["--version=branch"];

    tests = lib.genAttrs' [discord discord-ptb discord-canary discord-development] (
      p: lib.nameValuePair p.pname p.tests.withEquicord
    );
  };

  meta = {
    description = "Other cutest Discord client mod";
    homepage = "https://github.com/Equicord/Equicord";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    maintainers = [maintainers.chiko];
  };
})
