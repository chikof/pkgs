{
  pkgs,
  maintainers,
}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
in {
  equibop = pkgs.callPackage ./equibop.nix {inherit sources maintainers;};
  unfetch = pkgs.callPackage ./unfetch.nix {inherit sources maintainers;};
  g = pkgs.callPackage ./g.nix {inherit sources maintainers;};
  nano-ffmpeg = pkgs.callPackage ./nano-ffmpeg.nix {inherit sources maintainers;};
  cavemem = pkgs.callPackage ./cavemem.nix {inherit sources maintainers;};
  typescript-svelte-plugin = pkgs.callPackage ./typescript-svelte-plugin.nix {inherit sources maintainers;};
  fallow = pkgs.callPackage ./fallow.nix {inherit sources maintainers;};
  grompt = pkgs.callPackage ./grompt.nix {inherit sources maintainers;};
  graphify = pkgs.python3Packages.callPackage ./graphify.nix {inherit sources maintainers;};

  vimPlugins = pkgs.vimPlugins // import ./vim-plugins {inherit pkgs sources maintainers;};
}
