{
  lib,
  fetchFromGitHub,
  rustPlatform,
  versionCheckHook,
  vimUtils,
  maintainers,
}: let
  version = "2.3.29";
  src = fetchFromGitHub {
    owner = "vyfor";
    repo = "cord.nvim";
    tag = "v${version}";
    hash = "sha256-zQNkfw3YrEvs9JMgC5UnVE09S/bCIRT+R1j4KaAA0Kc=";
  };
  cord-server = rustPlatform.buildRustPackage {
    pname = "cord";
    inherit src version;
    cargoHash = "sha256-f2bYDfWFfOm2H4iy0FS4g3NFW7uTB5/1CE7AQSr5llM=";

    # The version in .github/server-version.txt differs from the one in Cargo.toml
    postPatch = ''
      echo "${version}" > .github/server-version.txt
    '';

    # cord depends on nightly features
    RUSTC_BOOTSTRAP = 1;

    nativeInstallCheckInputs = [
      versionCheckHook
    ];
    doInstallCheck = false;

    meta.mainProgram = "cord";
  };
in
  vimUtils.buildVimPlugin {
    pname = "cord.nvim";
    inherit src version;

    # Patch the logic used to find the path to the cord server
    # This still lets the user set config.advanced.server.executable_path
    # https://github.com/vyfor/cord.nvim/blob/v2.2.3/lua/cord/server/fs/init.lua#L10-L15
    postPatch = ''
      substituteInPlace lua/cord/server/fs/init.lua \
        --replace-fail \
          "or M.get_data_path()" \
          "or '${cord-server}'"
      echo "${version}" > .github/server-metadata.txt
    '';

    nvimSkipModules = [
      "cord.api.log.file"
    ];

    passthru = {
      # cargoHash lives on the server; scripts/update.sh bumps it as a subpackage
      updateArgs = ["--subpackage" "cord-server"];

      # nix-update --subpackage resolves this
      inherit cord-server;
    };

    meta = {
      homepage = "https://github.com/vyfor/cord.nvim";
      license = lib.licenses.asl20;
      changelog = "https://github.com/vyfor/cord.nvim/releases/tag/v${version}";
      maintainers = [maintainers.chiko];
    };
  }
