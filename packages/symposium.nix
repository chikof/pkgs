{
  lib,
  rustPlatform,
  makeWrapper,
  cargo,
  maintainers,
  sources,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "symposium";
  version = lib.removePrefix "symposium-v" sources.symposium.version;

  inherit (sources.symposium) src;
  cargoLock = sources.symposium.cargoLock."Cargo.lock";

  # v0.5.1 exits 1 with no reason when a plugin hook blocks a call; fixed upstream on main (exit 2 + stderr)
  patches = [./symposium-hook-block-exit-2.patch];

  # tests fetch crates.io / git sources
  doCheck = false;

  __structuredAttrs = true;

  nativeBuildInputs = [makeWrapper];

  # `cargo agents sync` shells out to `cargo metadata`; suffix so a project toolchain wins
  postInstall = ''
    wrapProgram $out/bin/cargo-agents --suffix PATH : ${lib.makeBinPath [cargo]}
  '';

  meta = {
    description = "Installs per-crate skills, hooks and MCP servers into AI coding agents (cargo agents)";
    homepage = "https://symposium.dev";
    changelog = "https://github.com/symposium-dev/symposium/releases/tag/symposium-v${finalAttrs.version}";
    license = with lib.licenses; [mit asl20];
    maintainers = [maintainers.chiko];
    mainProgram = "cargo-agents";
  };
})
