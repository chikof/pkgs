{
  lib,
  buildGoModule,
  fetchFromCodeberg,
  maintainers,
}:
buildGoModule (finalAttrs: {
  pname = "grompt";
  version = "0-unstable-2026-10-11";

  src = fetchFromCodeberg {
    owner = "estebxn";
    repo = "grompt";
    rev = "7633784e1b838faa11c55ff3166c2a29abd1790a";
    hash = "sha256-Heskjt1Cn0HQcGMkumu0G9upP+MBPL43xTwy+4IGKnk=";
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
