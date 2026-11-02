{
  lib,
  fetchFromGitHub,
  rustPlatform,
  vimUtils,
  maintainers,
}: let
  version = "2.3.29";
  src = fetchFromGitHub {
    owner = "chikof";
    repo = "duvet.nvim";
    tag = "v${version}";
    hash = "sha256-V5HknKS0f0DkCU5wK/NuhudXjLOApg/Pao2xUiP4iEM=";
  };
  duvet-server = rustPlatform.buildRustPackage {
    pname = "duvet";
    inherit src version;
    cargoLock.lockFile = src + "/Cargo.lock";

    meta.mainProgram = "duvet";
  };
in
  vimUtils.buildVimPlugin {
    pname = "duvet.nvim";
    inherit src version;

    # Point the server lookup at the store path; users can still set advanced.server.executable_path
    # (lua/duvet/server/fs/init.lua: `<dir>/bin/duvet`).
    postPatch = ''
      substituteInPlace lua/duvet/server/fs/init.lua \
        --replace-fail \
          "or M.get_data_path()" \
          "or '${duvet-server}'"
      echo "${version}" > .github/server-metadata.txt
    '';

    nvimSkipModules = [
      "duvet.api.log.file"
    ];

    passthru = {inherit duvet-server;};

    meta = {
      homepage = "https://github.com/chikof/duvet.nvim";
      license = lib.licenses.asl20;
      maintainers = [maintainers.chiko];
    };
  }
