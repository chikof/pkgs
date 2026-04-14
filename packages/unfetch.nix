{
  lib,
  stdenv,
  buildGo125Module,
  sources,
  maintainers,
}:
buildGo125Module (finalAttrs: {
  pname = "unfetch";
  version = "unstable-${sources.unfetch.date}";

  inherit (sources.unfetch) src;

  vendorHash = null;
  ldflags = ["-s" "-w"];

  meta = {
    description = "Simple and customizable system fetch";
    homepage = "https://codeberg.org/ungo/unfetch";
    license = lib.licenses.cc0;
    maintainers = [maintainers.chiko];
    mainProgram = "unfetch";
  };
})
