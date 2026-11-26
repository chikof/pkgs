{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  maintainers,
}:
buildNpmPackage (finalAttrs: {
  pname = "robloxstudio-mcp";
  version = "3.6.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@chrrxs/robloxstudio-mcp/-/robloxstudio-mcp-${finalAttrs.version}.tgz";
    hash = "sha256-2E0UES1WTnoHnlr81N01KAv9iAv7drwtwr+6MRQML+8=";
  };

  sourceRoot = "package";

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./robloxstudio-mcp-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-3vNZFWtQP50LXId17wvYZTMytDMEVw/DO1ODOS6QjWY=";

  # scripts/update.sh regenerates the lockfile (devDependencies stripped, as in postPatch) on each bump
  passthru.npmLock = {
    file = "packages/robloxstudio-mcp/robloxstudio-mcp-package-lock.json";
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
