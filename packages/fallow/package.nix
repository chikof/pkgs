{
  lib,
  fetchFromGitHub,
  gitMinimal,
  rustPlatform,
  versionCheckHook,
  maintainers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fallow";

  version = "3.47.0";

  src = fetchFromGitHub {
    owner = "fallow-rs";
    repo = "fallow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-bIqT4TbLgndEXeZ9vbg0+4OwxaP6abKd2/nbon9UW9s=";
  };

  cargoHash = "sha256-De7FmHYcYII3Evk2AuDAHBeAH5Ujbuo6xwZmog3+G6E=";

  doCheck = false;

  __structuredAttrs = true;

  buildAndTestSubdir = "crates/cli";

  nativeCheckInputs = [
    gitMinimal
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [versionCheckHook];

  meta = {
    description = "Rust-native codebase intelligence for TypeScript and JavaScript";
    homepage = "https://docs.fallow.tools";
    changelog = "https://github.com/fallow-rs/fallow/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "fallow";
  };
})
