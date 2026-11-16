{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  maintainers,
}:
buildNpmPackage (finalAttrs: {
  pname = "robloxstudio-mcp";
  version = "3.5.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@chrrxs/robloxstudio-mcp/-/robloxstudio-mcp-${finalAttrs.version}.tgz";
    hash = "sha256-P4zN3EJxX2vL5SRxtIXM/avA+8nZ59S5+Mw+InJhYks=";
  };

  sourceRoot = "package";

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./robloxstudio-mcp-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-qQQvB7M5G+ATlpFk/UT8h30szSfMKAVNm5VDiyPTE4s=";

  # scripts/update.sh regenerates the lockfile (devDependencies stripped, as in postPatch) on each bump
  passthru.npmLock = {
    file = "robloxstudio-mcp-package-lock.json";
    jq = "del(.devDependencies, .scripts)";
  };

  # dist/ is prebuilt in the tarball
  dontNpmBuild = true;
  npmFlags = ["--ignore-scripts"];

  meta = {
    description = "MCP server for Roblox Studio: playtests, runtime eval, screenshots, edits";
    homepage = "https://github.com/Chrrxs/robloxstudio-mcp";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "robloxstudio-mcp";
  };
})
