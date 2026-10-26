{
  lib,
  buildGoModule,
  fetchFromCodeberg,
  maintainers,
}:
buildGoModule (finalAttrs: {
  pname = "grompt";
  version = "0-unstable-2026-10-18";

  src = fetchFromCodeberg {
    owner = "estebxn";
    repo = "grompt";
    rev = "468241ab7d20d89948ca5849d25c9759a253642c";
    hash = "sha256-rNP08TG1WLeBE1X93M+Rip7vaNRHivxr8BvmXvlqdg0=";
  };

  vendorHash = null;
  ldflags = ["-s" "-w"];

  passthru.updateArgs = ["--version=branch"];

  meta = {
    description = "starship.rs killer";
    homepage = "https://codeberg.org/estebxn/grompt";
    license = lib.licenses.cc0;
    maintainers = [maintainers.chiko];
    mainProgram = "grompt";
  };
})
