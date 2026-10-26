{
  sigrok-cli,
  fetchurl,
}:
# REA hard-requires sigrok-cli 0.7.2; nixpkgs ships an unstable 0.8.0 snapshot.
sigrok-cli.overrideAttrs (_: {
  version = "0.7.2";
  src = fetchurl {
    url = "https://sigrok.org/download/source/sigrok-cli/sigrok-cli-0.7.2.tar.gz";
    hash = "sha256-cdBEPzaJe/Vlcy3sIGgw2+oPJ4m2YBzxBTayhtEUCrg=";
  };
})
