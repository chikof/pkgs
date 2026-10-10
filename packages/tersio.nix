{
  lib,
  buildNpmPackage,
  jq,
  makeWrapper,
  rtk,
  sqlite,
  maintainers,
  sources,
}:
buildNpmPackage {
  inherit (sources.tersio) pname version src;

  sourceRoot = "package";

  nativeBuildInputs = [makeWrapper];

  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./tersio-package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-Iut8uOC8KR2iQVn7o0/G86FV3UmiKgwgNEf9zfzhPEY=";

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
}
