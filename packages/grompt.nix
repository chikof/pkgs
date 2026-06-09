{
  lib,
  buildGoModule,
  sources,
  maintainers,
}:
buildGoModule (finalAttrs: {
  pname = "grompt";
  version = "unstable-${sources.grompt.date}";

  inherit (sources.grompt) src;

  vendorHash = null;
  ldflags = ["-s" "-w"];

  meta = {
    description = "starship.rs killer";
    homepage = "https://codeberg.org/estebxn/grompt";
    license = lib.licenses.cc0;
    maintainers = [maintainers.chiko];
    mainProgram = "grompt";
  };
})
