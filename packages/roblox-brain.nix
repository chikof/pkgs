{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  maintainers,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "roblox-brain";
  version = "2.3.1";

  src = fetchFromGitHub {
    owner = "TabooHarmony";
    repo = "roblox-brain";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Y2v0i015kVbREUWdVD7KyG/8DB5KH0ijZykjdzKnVNA=";
  };

  dontBuild = true;

  # Luau, architecture, security and map-building skills only. Left out on purpose: collaboration-mode
  # (claims precedence over project AGENTS.md), studio-mcp and tooling (overlap the vjnew roblox skills
  # and contradict its "scripts only in src/" rule), plus the design/monetization/cloud libraries.
  installPhase = ''
    runHook preInstall
    dest=$out/share/roblox-brain/skills
    mkdir -p $dest
    for s in core/roblox-luau-core core/roblox-luau-types core/roblox-luau-patterns core/roblox-architecture \
             core/roblox-networking core/roblox-security core/roblox-performance \
             gameplay/roblox-building gameplay/roblox-lighting gameplay/roblox-gui; do
      cp -r skills/$s $dest/
    done
    runHook postInstall
  '';

  meta = {
    description = "Roblox Studio knowledge skills for coding agents (Luau, architecture, networking, security, building)";
    homepage = "https://github.com/TabooHarmony/roblox-brain";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    platforms = lib.platforms.all;
  };
})
