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
  version = "0-unstable-2026-10-31";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    rev = "00abcbeea2ddf4317e02843418f267db62bcb913";
    hash = "sha256-BfthELkW+p0sF8A0zywJVT2Y6XBSyS0PJK5HjOLSr0c=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-M4mrhAMDh+HP5O6gJobUcrr/EkcC9V1E+2JdZHWufdU=";
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
