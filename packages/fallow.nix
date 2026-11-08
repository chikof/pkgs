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

  version = "3.41.0";

  src = fetchFromGitHub {
    owner = "fallow-rs";
    repo = "fallow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BTyPlyYukd/2nWQv6Ox7tqah5LfdJKUyxKAD+U/cgjA=";
  };

  cargoHash = "sha256-Cib4SkPoP+N43wGpEbPBvsPfuc7sq3pgdL22/wP3k/M=";

  doCheck = false;

  __structuredAttrs = true;

  buildAndTestSubdir = "crates/cli";

  nativeCheckInputs = [
    gitMinimal
  ];

  doInstallCheck = false;
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
