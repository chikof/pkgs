{
  lib,
  buildGoModule,
  fetchFromGitHub,
  maintainers,
}:
buildGoModule (finalAttrs: {
  pname = "nano-ffmpeg";
  version = "0-unstable-2026-04-25";

  src = fetchFromGitHub {
    owner = "dgr8akki";
    repo = "nano-ffmpeg";
    rev = "f51b0acc157f96682e2f93a5b994766b039ec2ba";
    hash = "sha256-4uZ2y+Qe4uMrnpzl8BHQEWFNkhwNBBwoxb5RMnLyGfM=";
  };

  vendorHash = "sha256-irJksXupZGHzZ5vbFeI9laKi5+LyATc1lMxpMLLl69w=";
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
