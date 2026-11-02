{
  lib,
  fetchFromGitHub,
  rustPlatform,
  maintainers,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bacon-ls";

  version = "0.32.0";

  src = fetchFromGitHub {
    owner = "crisidev";
    repo = "bacon-ls";
    tag = finalAttrs.version;
    hash = "sha256-naYrk46QDH9vBp0jBuHKdZzvjwbJ4uj1Arim7Em+yb4=";
  };

  cargoHash = "sha256-92PHdHxZaayTH9xj/YrAuMoeiRz8rY5ihNxWYM+e90c=";

  # tests spawn cargo/bacon, unavailable in the sandbox
  doCheck = false;

  __structuredAttrs = true;

  meta = {
    description = "LSP server exposing cargo/bacon diagnostics for Rust";
    homepage = "https://github.com/crisidev/bacon-ls";
    changelog = "https://github.com/crisidev/bacon-ls/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "bacon-ls";
  };
})
