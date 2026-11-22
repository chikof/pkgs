{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  maintainers,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "security-audit-skill";
  version = "0-unstable-2026-09-14";

  src = fetchFromGitHub {
    owner = "cloudflare";
    repo = "security-audit-skill";
    rev = "c1c8a8c1471069fb0e188eeaff69b8e8db6564a8";
    hash = "sha256-oVVACjotkHvllQGxEP8yWaEt4c3GxT0d909TUM5P3NM=";
  };

  dontBuild = true;

  # agent skills dir for omp `skills.customDirectories`; the validators in it need node on PATH
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/security-audit-skill/skills
    cp -r skills/security-audit $out/share/security-audit-skill/skills/
    runHook postInstall
  '';

  passthru.updateArgs = ["--version=branch"];

  meta = {
    description = "Agent skill for multi-phase security audits with independently verified findings";
    homepage = "https://github.com/cloudflare/security-audit-skill";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    platforms = lib.platforms.all;
  };
})
