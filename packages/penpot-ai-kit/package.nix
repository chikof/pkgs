{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  maintainers,
}:
stdenvNoCC.mkDerivation {
  pname = "penpot-ai-kit";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "penpot";
    repo = "penpot-ai-kit";
    tag = "v0.5.1";
    hash = "sha256-LfgHzSbkqlrTPG0FDiDsokMsx9qdScZteXEIL3EmMvI=";
  };

  dontBuild = true;

  # skills cite shared/ and policies/ by relative path; the kit's own installer vendors them into each skill, workflows/ only into the router
  installPhase = ''
    runHook preInstall
    dest=$out/share/penpot-ai-kit/skills
    mkdir -p $dest
    for s in skills/*/; do
      name=$(basename $s)
      cp -r $s $dest/$name
      chmod -R u+w $dest/$name
      cp -r shared policies $dest/$name/
    done
    chmod -R u+w $dest/penpot-router
    cp -r workflows $dest/penpot-router/
    runHook postInstall
  '';

  meta = {
    description = "Penpot AI Kit: agent skills that drive Penpot through its MCP (tokens, components, screens, decks, audits, Figma migration)";
    homepage = "https://github.com/penpot/penpot-ai-kit";
    license = lib.licenses.cc-by-40;
    maintainers = [maintainers.chiko];
    platforms = lib.platforms.all;
  };
}
