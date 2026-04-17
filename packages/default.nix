{
  pkgs,
  maintainers,
}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
in {
  equibop = pkgs.callPackage ./equibop.nix {inherit sources maintainers;};
  unfetch = pkgs.callPackage ./unfetch.nix {inherit sources maintainers;};
  nano-ffmpeg = pkgs.callPackage ./nano-ffmpeg.nix {inherit sources maintainers;};

  vimPlugins = pkgs.vimPlugins // import ./vim-plugins {inherit pkgs sources maintainers;};
}
