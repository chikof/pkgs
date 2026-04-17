{
  lib,
  buildGoModule,
  sources,
  maintainers,
}:
buildGoModule (finalAttrs: {
  pname = "nano-ffmpeg";
  version = "unstable-${sources.nano-ffmpeg.date}";

  inherit (sources.nano-ffmpeg) src;

  vendorHash = "sha256-irJksXupZGHzZ5vbFeI9laKi5+LyATc1lMxpMLLl69w=";
  ldflags = ["-s" "-w"];

  meta = {
    description = "ffmpeg made easy";
    homepage = "https://github.com/dgr8akki/nano-ffmpeg";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "nano-ffmpeg";
  };
})
