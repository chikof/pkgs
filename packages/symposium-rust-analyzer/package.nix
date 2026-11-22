{
  lib,
  fetchFromGitHub,
  rustPlatform,
  makeWrapper,
  rust-analyzer,
  maintainers,
}:
rustPlatform.buildRustPackage {
  pname = "symposium-rust-analyzer";
  version = "0.1.1-unstable-2026-05-20";

  src = fetchFromGitHub {
    owner = "symposium-dev";
    repo = "symposium-rust-analyzer";
    rev = "d16d8c34ea80317b222a06aad8010d2d79a2a26c";
    hash = "sha256-FQhUstgGMzEYGTFTm7QBjI8+VLus0KgRiBIPI4x2cUA=";
  };

  cargoHash = "sha256-Zj5TJaiJCjuz1sYXP5OnGoFLIDB0xgCpzGSCBwQ/UFQ=";

  passthru.updateArgs = ["--version=branch"];

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
