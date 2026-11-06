{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  maintainers,
}:
buildNpmPackage (finalAttrs: {
  pname = "figma-developer-mcp";
  version = "0.13.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/figma-developer-mcp/-/figma-developer-mcp-${finalAttrs.version}.tgz";
    hash = "sha256-R15dTXU0UeCHvLQC1nKDFz2XtnHD+f4dRu35y4DXqTo=";
  };

  sourceRoot = "package";

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./figma-developer-mcp-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-oukq8aRIy6L317Tgt5ta/YYvQwGHI0jT4wXYmX5Aew8=";

  # scripts/update.sh regenerates the lockfile (devDependencies stripped, as in postPatch) on each bump
  passthru.npmLock = {
    file = "figma-developer-mcp-package-lock.json";
    jq = "del(.devDependencies, .scripts)";
  };

  # dist/ is prebuilt in the tarball
  dontNpmBuild = true;
  npmFlags = ["--ignore-scripts"];

  meta = {
    description = "Figma MCP server (Framelink) that reads designs through a personal access token; works with any MCP client";
    homepage = "https://github.com/GLips/Figma-Context-MCP";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "figma-developer-mcp";
  };
})
