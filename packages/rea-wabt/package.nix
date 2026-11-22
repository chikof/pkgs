{
  wabt,
  fetchurl,
}:
# REA hard-requires the exact WABT 1.0.42 version banner; nixpkgs ships 1.0.41.
wabt.overrideAttrs (_: rec {
  version = "1.0.42";
  src = fetchurl {
    url = "https://github.com/WebAssembly/wabt/releases/download/${version}/wabt-${version}.tar.xz";
    hash = "sha256-p2zaPBdKQwl4Y6B/wLDCAvdw9T4hgG6iY28WfR/7HjA=";
  };
})
