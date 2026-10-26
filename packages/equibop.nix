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
  version = "0-unstable-2026-10-09";

  src = fetchFromGitHub {
    owner = "Equicord";
    repo = "Equicord";
    rev = "e0e85c8d4f6dc73aac9368cf3f4b2200eac4d4b4";
    hash = "sha256-jnfVr39Oag+DqobGmvIIv4JBOZt+eHQnyNct+SagcvI=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-9DNn38JdFQMQh48UEJo5d6CUMbjlzs5LEma6095o508=";
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
