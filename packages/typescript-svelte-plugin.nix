{
  lib,
  stdenvNoCC,
  sources,
  maintainers,
}:
stdenvNoCC.mkDerivation {
  inherit (sources.typescript-svelte-plugin) pname version src;

  sourceRoot = "package";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/lib/node_modules/typescript-svelte-plugin
    cp -r . $out/lib/node_modules/typescript-svelte-plugin/
  '';

  meta = {
    description = "TypeScript plugin for Svelte";
    homepage = "https://github.com/sveltejs/language-tools/tree/master/packages/typescript-plugin";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
  };
}
