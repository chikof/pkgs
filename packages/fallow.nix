{
  lib,
  gitMinimal,
  rustPlatform,
  versionCheckHook,
  maintainers,
  sources,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fallow";

  inherit (sources.fallow) src version;
  cargoLock = sources.fallow.cargoLock."Cargo.lock";

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
