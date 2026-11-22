{
  lib,
  buildGoModule,
  fetchFromCodeberg,
  maintainers,
}:
buildGoModule (finalAttrs: {
  pname = "g";
  version = "0-unstable-2026-04-26";

  src = fetchFromCodeberg {
    owner = "ungo";
    repo = "g";
    rev = "e102a8b8ab8fc5ffd5b12c6b0e1b06c92914896a";
    hash = "sha256-sNQchzOsvp+iMpk8deBBJpFR01Ks5ukS8Z/Mr58kVRM=";
  };

  vendorHash = null;
  ldflags = ["-s" "-w"];

  passthru.updateArgs = ["--version=branch"];

  meta = {
    description = "Simple and customizable system fetch";
    homepage = "https://codeberg.org/ungo/g";
    license = lib.licenses.cc0;
    maintainers = [maintainers.chiko];
    mainProgram = "g";
  };
})
