{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  makeWrapper,
  ghidra,
  binwalk,
  unblob,
  util-linux,
  jdk21,
  nodejs_24,
  wireshark-cli,
  mitmproxy,
  binutils,
  gdb,
  rizin,
  ilspycmd,
  apktool,
  android-tools,
  chromium,
  rea-wabt,
  rea-sigrok-cli,
  rea-pwndbg,
  rea-pwntools-python,
  kuna,
  wakaru,
  jadx-headless-mcp,
  maintainers,
}: let
  prlimit = lib.getExe' util-linux "prlimit";
  # every REA tool path must be absolute; defaults only so a caller can still override
  env = {
    GHIDRA_INSTALL_DIR = "${ghidra}/lib/ghidra";
    JAVA_HOME = "${jdk21}";

    # firmware
    REA_BINWALK_COMMAND = lib.getExe binwalk;
    REA_UNBLOB_COMMAND = lib.getExe unblob;
    REA_FIRMWARE_PRLIMIT_COMMAND = prlimit;

    # packet captures
    REA_TSHARK_COMMAND = lib.getExe' wireshark-cli "tshark";
    REA_CAPINFOS_COMMAND = lib.getExe' wireshark-cli "capinfos";
    REA_TSHARK_PRLIMIT_COMMAND = prlimit;
    REA_MITMDUMP_COMMAND = lib.getExe' mitmproxy "mitmdump";

    # signals, wasm, javascript, evm
    REA_SIGROK_COMMAND = lib.getExe rea-sigrok-cli;
    REA_SIGROK_PRLIMIT_COMMAND = prlimit;
    REA_WABT_BIN_DIRECTORY = "${rea-wabt}/bin";
    REA_WAKARU_COMMAND = lib.getExe wakaru;
    REA_JAVASCRIPT_PRLIMIT_COMMAND = prlimit;
    REA_EVM_PRLIMIT_COMMAND = prlimit;
    REA_BROWSER_EXECUTABLE = lib.getExe chromium;

    # native debugging and disassembly
    REA_GDB_COMMAND = lib.getExe gdb;
    REA_OBJDUMP_COMMAND = lib.getExe' binutils "objdump";
    REA_RIZIN_COMMAND = lib.getExe rizin;
    REA_KUNA_COMMAND = lib.getExe kuna;
    REA_PWNTOOLS_PYTHON = lib.getExe' rea-pwntools-python "python3";
    REA_PWNDBG_GDB = rea-pwndbg.gdb;
    REA_PWNDBG_GDBINIT = rea-pwndbg.gdbinit;
    REA_PWNDBG_VENV_PATH = rea-pwndbg.venv;

    # managed and android
    REA_ILSPY_CMD_PATH = lib.getExe ilspycmd;
    REA_APKTOOL_COMMAND = lib.getExe apktool;
    REA_ADB_PATH = lib.getExe' android-tools "adb";
    REA_JADX_MCP_JAR = "${jadx-headless-mcp}/share/java/jadx-headless-mcp.jar";
  };
in
  buildNpmPackage (finalAttrs: {
    pname = "rea";
    version = "6.7.0";

    src = fetchurl {
      url = "https://registry.npmjs.org/rea-agents/-/rea-agents-${finalAttrs.version}.tgz";
      hash = "sha256-IJWKZtuhoBHlCkhr65Rjo0MSjtNoyYT5QGU2LBP1H5A=";
    };

    # ponytail: frida (optional dep, native prebuilds) dropped; add back with a prebuilt-fetching override if dynamic instrumentation is needed.
    nodejs = nodejs_24;
    nativeBuildInputs = [makeWrapper];
    sourceRoot = "package";

    postPatch = ''
      ${lib.getExe jq} 'del(.devDependencies, .optionalDependencies)' package.json > package.json.new
      mv package.json.new package.json
      cp ${./rea-package-lock.json} package-lock.json
    '';

    npmDepsHash = "sha256-L1oa5cvF9MbefEOWP8+i7UpMy8SOA9L2geBYGWmT21E=";

    # scripts/update.sh regenerates the lockfile (dev/optional deps stripped, as in postPatch) on each bump
    passthru.npmLock = {
      file = "rea-package-lock.json";
      jq = "del(.devDependencies, .optionalDependencies)";
    };

    # dist/ is prebuilt
    dontNpmBuild = true;
    npmFlags = ["--ignore-scripts"];

    # REA never discovers tools itself: every provider needs an absolute path, and NixOS has no /usr/bin/{prlimit,gdb}.
    # --set-default keeps a caller's own value winning.
    postInstall = ''
      wrapProgram $out/bin/rea \
        ${lib.concatStringsSep " \\\n      " (lib.mapAttrsToList (k: v: "--set-default ${k} ${lib.escapeShellArg v}") env)}
    '';

    meta = {
      description = "Reverse engineer anything with agents: one MCP for binaries, apps and runtime behavior";
      homepage = "https://github.com/morluto/rea";
      license = lib.licenses.mit;
      maintainers = [maintainers.chiko];
      mainProgram = "rea";
    };
  })
