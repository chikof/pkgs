{
  lib,
  buildGoModule,
  fetchFromCodeberg,
  maintainers,
}:
buildGoModule (finalAttrs: {
  pname = "unfetch";
  version = "0-unstable-2026-03-11";

  src = fetchFromCodeberg {
    owner = "ungo";
    repo = "unfetch";
    rev = "76f2a2fb1ce40b352c505fa3e5e47effa6654246";
    hash = "sha256-Yv7U6n+xMgFhawGP9mU0h1gjkn4VLTgKTHeNt7Hb0js=";
  };

  vendorHash = null;
  ldflags = ["-s" "-w"];

  passthru.updateArgs = ["--version=branch"];

  meta = {
    description = "Simple and customizable system fetch";
    homepage = "https://codeberg.org/ungo/unfetch";
    license = lib.licenses.cc0;
    maintainers = [maintainers.chiko];
    mainProgram = "unfetch";
  };
})
