{
  lib,
  stdenvNoCC,
  fetchurl,
  maintainers,
}:
# REA hard-requires pwndbg 2026.09.15 exactly. The upstream portable build ships its own
# loader, glibc, python and gdb, so it runs unpatched on NixOS.
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rea-pwndbg";
  version = "2026.09.15";

  src = fetchurl {
    url = "https://github.com/pwndbg/pwndbg/releases/download/${finalAttrs.version}/pwndbg_${finalAttrs.version}_x86_64-portable.tar.xz";
    hash = "sha256-e6ZGZu5ZWIW6Sw4HP4XkI4KRA+n9vpIbpO7xrNkVCAM=";
  };

  # the portable tarball omits the repo-root gdbinit.py that REA must exec; it fixes sys.path from PWNDBG_VENV_PATH, then loads pwndbg
  gdbinitSrc = fetchurl {
    url = "https://raw.githubusercontent.com/pwndbg/pwndbg/${finalAttrs.version}/gdbinit.py";
    hash = "sha256-Adj1PIl0VuGoYFr+tJwMmNeHsglWpQLnPIaHAB7/GJs=";
  };

  sourceRoot = ".";

  # relocatable by design: patchShebangs/patchelf/strip would break it
  dontFixup = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share
    cp -r pwndbg $out/share/pwndbg
    install -Dm644 ${finalAttrs.gdbinitSrc} $out/share/pwndbg/gdbinit.py
    runHook postInstall
  '';

  passthru = {
    gdb = "${finalAttrs.finalPackage}/share/pwndbg/bin/gdb";
    gdbinit = "${finalAttrs.finalPackage}/share/pwndbg/gdbinit.py";
    venv = "${finalAttrs.finalPackage}/share/pwndbg";
  };

  meta = {
    description = "pwndbg portable build (bundled gdb and python), pinned for REA";
    homepage = "https://github.com/pwndbg/pwndbg";
    license = lib.licenses.mit;
    maintainers = [maintainers.chiko];
    platforms = ["x86_64-linux"];
    sourceProvenance = [lib.sourceTypes.binaryNativeCode];
  };
})
