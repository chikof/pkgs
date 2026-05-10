{
  lib,
  buildGoModule,
  sources,
  maintainers,
}:
buildGoModule (finalAttrs: {
  pname = "g";
  version = "unstable-${sources.g.date}";

  inherit (sources.g) src;

  vendorHash = null;
  ldflags = ["-s" "-w"];

  meta = {
    description = "Simple and customizable system fetch";
    homepage = "https://codeberg.org/ungo/g";
    license = lib.licenses.cc0;
    maintainers = [maintainers.chiko];
    mainProgram = "g";
  };
})
