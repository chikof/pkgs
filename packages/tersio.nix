{
  lib,
  buildNpmPackage,
  fetchurl,
  jq,
  makeWrapper,
  rtk,
  sqlite,
  maintainers,
}:
buildNpmPackage (finalAttrs: {
  pname = "tersio";
  version = "2.25.15";

  src = fetchurl {
    url = "https://registry.npmjs.org/@krtclcdy/tersio/-/tersio-${finalAttrs.version}.tgz";
    hash = "sha256-O9DY1agOjMzC6pHS1ubHVY4SyJDnJiFk4KfhINvUq14=";
  };

  sourceRoot = "package";

  nativeBuildInputs = [makeWrapper];

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./tersio-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-wRF72nb/T14c0faU8wpUkbhBlJzIi86dHrQULW2R93o=";

  # scripts/update.sh regenerates the lockfile (devDependencies stripped, as in postPatch) on each bump
  passthru.npmLock = {
    file = "tersio-package-lock.json";
    jq = "del(.devDependencies)";
  };

  # dist/ is prebuilt in the tarball
  dontNpmBuild = true;

  postInstall = ''
    wrapProgram $out/bin/tersio --prefix PATH : ${lib.makeBinPath [rtk sqlite]}
  '';

  meta = {
    description = "Token saver and usage tracker for coding agents (caveman, rtk, ponytail, gain dashboard)";
    homepage = "https://github.com/KurutoDenzeru/tersio";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "tersio";
  };
})
