{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  maintainers,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "taste-skill";
  version = "2.1.5";

  src = fetchFromGitHub {
    owner = "Leonxlnx";
    repo = "taste-skill";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RpdiP+9Rh1sfPTsGnrKMmCiNT7T9l0/jnDrDYoAJukY=";
  };

  dontBuild = true;

  # agent skills dir for omp `skills.customDirectories`; SKILL.md frontmatter name is design-taste-frontend
  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/taste-skill/skills
    cp -r skills/taste-skill $out/share/taste-skill/skills/design-taste-frontend
    runHook postInstall
  '';

  meta = {
    description = "Agent skill that makes coding agents design websites and app screens instead of assembling the average landing page";
    homepage = "https://github.com/Leonxlnx/taste-skill";
    changelog = "https://github.com/Leonxlnx/taste-skill/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    platforms = lib.platforms.all;
  };
})
