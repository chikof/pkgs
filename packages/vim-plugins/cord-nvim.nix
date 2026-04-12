{
  lib,
  rustPlatform,
  versionCheckHook,
  nix-update-script,
  vimUtils,
  sources,
  maintainers,
}: let
  inherit (sources.cord-nvim) src version;
  cargoLock = sources.cord-nvim.cargoLock."Cargo.lock";
  cord-server = rustPlatform.buildRustPackage {
    pname = "cord";
    inherit src version cargoLock;

    # The version in .github/server-version.txt differs from the one in Cargo.toml
    postPatch = ''
      echo "${lib.removePrefix "v" version}" > .github/server-version.txt
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
    '';

    nvimSkipModules = [
      "cord.api.log.file"
    ];

    passthru = {
      updateScript = nix-update-script {
        attrPath = "vimPlugins.cord-nvim.cord-nvim-rust";
      };

      # needed for the update script
      inherit cord-server;
    };

    meta = {
      homepage = "https://github.com/vyfor/cord.nvim";
      license = lib.licenses.asl20;
      changelog = "https://github.com/vyfor/cord.nvim/releases/tag/v${version}";
      maintainers = [maintainers.chiko];
    };
  }
