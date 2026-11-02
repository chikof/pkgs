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
  version = "2.25.16";

  src = fetchurl {
    url = "https://registry.npmjs.org/@krtclcdy/tersio/-/tersio-${finalAttrs.version}.tgz";
    hash = "sha256-MFHxdNSfntAEf98l5tC5LViSDhz2bN3oxSPquMOtlMQ=";
  };

  sourceRoot = "package";

  nativeBuildInputs = [makeWrapper];

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./tersio-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-hJDr15ObwU9aBhjeN6KBwTgpaaepa9NAvRIMxTkOYYw=";

  # scripts/update.sh regenerates the lockfile (devDependencies stripped, as in postPatch) on each bump
  passthru.npmLock = {
    file = "tersio-package-lock.json";
    jq = "del(.devDependencies)";
  };

  # dist/ is prebuilt in the tarball
  dontNpmBuild = true;

  # omp's own PI_CODING_AGENT_DIR is ignored by tersio (only honored when PI_CODING_AGENT=true), so point the
  # ledger and quota reads at the nix omp's data dir; env overrides still win
  postInstall = ''
    wrapProgram $out/bin/tersio \
      --prefix PATH : ${lib.makeBinPath [rtk sqlite]} \
      --run 'export TERSIO_SESSIONS_DIR="''${TERSIO_SESSIONS_DIR:-$HOME/.local/share/omp/sessions}"' \
      --run 'export TERSIO_AGENT_SESSIONS_DB="''${TERSIO_AGENT_SESSIONS_DB:-$HOME/.local/share/omp/agent.db}"'
  '';

  meta = {
    description = "Token saver and usage tracker for coding agents (caveman, rtk, ponytail, gain dashboard)";
    homepage = "https://github.com/KurutoDenzeru/tersio";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    mainProgram = "tersio";
  };
})
