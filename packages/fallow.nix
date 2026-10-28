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

  version = "3.37.0";

  src = fetchFromGitHub {
    owner = "fallow-rs";
    repo = "fallow";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NUdWxwapMozTlF92oZt0GORfYO0elIdzxmz8AzUIFfw=";
  };

  cargoHash = "sha256-mfnDXXyvhwlngDM7RqGb7O1hSlOw6CV8mG2jOuVRTbc=";

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
