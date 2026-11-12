{
  lib,
  buildGoModule,
  fetchFromGitHub,
  maintainers,
}:
buildGoModule (finalAttrs: {
  pname = "nano-ffmpeg";
  version = "0-unstable-2026-11-11";

  src = fetchFromGitHub {
    owner = "dgr8akki";
    repo = "nano-ffmpeg";
    rev = "8c7f7d3785f231414bee72db40b0f461b480b44a";
    hash = "sha256-QB/Z2vwaIjStyYFSFiFtVpUTxUHWrgs6YVmxfegfoYg=";
  };

  vendorHash = "sha256-AZzpINOagTfFPYOavp15oJD/LTlDoX4NfDA0DYV39NM=";
  ldflags = ["-s" "-w"];

  passthru.updateArgs = ["--version=branch"];

  meta = {
    description = "ffmpeg made easy";
    homepage = "https://github.com/dgr8akki/nano-ffmpeg";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "nano-ffmpeg";
  };
})
