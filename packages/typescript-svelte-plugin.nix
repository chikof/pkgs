{
  lib,
  fetchurl,
  stdenvNoCC,
  maintainers,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "typescript-svelte-plugin";
  version = "0.3.52";

  src = fetchurl {
    url = "https://registry.npmjs.org/typescript-svelte-plugin/-/typescript-svelte-plugin-${finalAttrs.version}.tgz";
    hash = "sha256-F0psKMVXJw4hSucCUtgHw/47uA0k+sbMqRdhZFTwAFo=";
  };

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
})
