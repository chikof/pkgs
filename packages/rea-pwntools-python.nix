{
  python3,
  fetchFromGitHub,
}:
# REA's pwntools lane hard-requires pwntools 4.15.0, pyelftools 0.33 and unicorn 2.1.2 (checked at runtime).
let
  python = python3.override {
    packageOverrides = final: prev: {
      pyelftools = prev.pyelftools.overridePythonAttrs (_: rec {
        version = "0.33";
        src = fetchFromGitHub {
          owner = "eliben";
          repo = "pyelftools";
          tag = "v${version}";
          hash = "sha256-NqF5A6PRl4uncwNS9j44fIV7ovlljiucvV2Msv0LK/w=";
        };
      });
      # the python binding builds from the C library's own source tree
      unicorn =
        (prev.unicorn.override {
          unicorn = final.pkgs.unicorn.overrideAttrs (old: rec {
            version = "2.1.2";
            src = fetchFromGitHub {
              owner = "unicorn-engine";
              repo = "unicorn";
              tag = version;
              hash = "sha256-qA84xBztyWmt/rUExhhZMkQzvDPx0UE9MAIPG/Su3iE=";
            };
          });
        }).overridePythonAttrs (old: {
          # 2.1.2 builds with versioningit; 2.1.4 (what nixpkgs expects) uses setuptools-scm
          build-system = old.build-system ++ [final.versioningit];
          # no git metadata in the store, so give versioningit a fallback version
          postPatch =
            (old.postPatch or "")
            + ''
              sed -i '/^\[tool.versioningit\]/a default-version = "2.1.2"' pyproject.toml
            '';
        });
    };
  };
in
  python.withPackages (ps: [ps.pwntools])
