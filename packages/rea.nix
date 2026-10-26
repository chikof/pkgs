{
  lib,
  buildNpmPackage,
  jq,
  makeWrapper,
  ghidra,
  binwalk,
  unblob,
  util-linux,
  jdk21,
  nodejs_24,
  maintainers,
  sources,
}:
buildNpmPackage {
  inherit (sources.rea) pname version src;

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

  # dist/ is prebuilt
  dontNpmBuild = true;
  npmFlags = ["--ignore-scripts"];

  # nixpkgs ghidra keeps the install root under lib/ghidra; REA needs Ghidra 12.1.x + JDK 21+
  # firmware tools need absolute paths (binwalk 3.1.x, unblob 26.6.x) and prlimit, which NixOS lacks at /usr/bin
  postInstall = ''
    wrapProgram $out/bin/rea \
      --set-default GHIDRA_INSTALL_DIR ${ghidra}/lib/ghidra \
      --set-default JAVA_HOME ${jdk21} \
      --set-default REA_BINWALK_COMMAND ${lib.getExe binwalk} \
      --set-default REA_UNBLOB_COMMAND ${lib.getExe unblob} \
      --set-default REA_FIRMWARE_PRLIMIT_COMMAND ${lib.getExe' util-linux "prlimit"}
  '';

  meta = {
    description = "Reverse engineer anything with agents: one MCP for binaries, apps and runtime behavior";
    homepage = "https://github.com/morluto/rea";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "rea";
  };
}
