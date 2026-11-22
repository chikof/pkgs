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

  version = "3.46.0";

  src = fetchFromGitHub {
    owner = "fallow-rs";
    repo = "fallow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AZ7KA6/GBnXaD4s7wJ77JbV4yMlvHDXGYnQjEg5pGqM=";
  };

  cargoHash = "sha256-RS7xygIeIUy4KpvtxmehQyG2nZBqc1ApW8dc7pN0ku4=";

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
