{
  lib,
  rustPlatform,
  makeWrapper,
  rust-analyzer,
  maintainers,
  sources,
}:
rustPlatform.buildRustPackage {
  pname = "symposium-rust-analyzer";
  version = "0.1.1-unstable-${sources.symposium-rust-analyzer.date}";

  inherit (sources.symposium-rust-analyzer) src;
  cargoLock = sources.symposium-rust-analyzer.cargoLock."Cargo.lock";

  # integration tests spawn rust-analyzer against a fixture project
  doCheck = false;

  __structuredAttrs = true;

  nativeBuildInputs = [makeWrapper];

  # tracing_subscriber::fmt() logs to stdout, which is the MCP transport; send logs to stderr
  postPatch = ''
    substituteInPlace src/main.rs \
      --replace-fail 'tracing_subscriber::fmt()' 'tracing_subscriber::fmt().with_writer(std::io::stderr)' \
      --replace-fail 'EnvFilter::new("debug")' 'EnvFilter::new("warn")'
  '';

  # suffix so a project toolchain's rust-analyzer wins
  postInstall = ''
    wrapProgram $out/bin/symposium-rust-analyzer --suffix PATH : ${lib.makeBinPath [rust-analyzer]}
  '';

  meta = {
    description = "MCP server exposing rust-analyzer LSP features (Symposium)";
    homepage = "https://github.com/symposium-dev/symposium-rust-analyzer";
    license = with lib.licenses; [mit asl20];
    maintainers = [maintainers.chiko];
    mainProgram = "symposium-rust-analyzer";
  };
}
