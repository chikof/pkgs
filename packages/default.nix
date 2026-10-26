{
  pkgs,
  maintainers,
}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
in rec {
  equibop = pkgs.callPackage ./equibop.nix {inherit sources maintainers;};
  unfetch = pkgs.callPackage ./unfetch.nix {inherit sources maintainers;};
  g = pkgs.callPackage ./g.nix {inherit sources maintainers;};
  nano-ffmpeg = pkgs.callPackage ./nano-ffmpeg.nix {inherit sources maintainers;};
  cavemem = pkgs.callPackage ./cavemem.nix {inherit sources maintainers;};
  typescript-svelte-plugin = pkgs.callPackage ./typescript-svelte-plugin.nix {inherit sources maintainers;};
  fallow = pkgs.callPackage ./fallow.nix {inherit sources maintainers;};
  grompt = pkgs.callPackage ./grompt.nix {inherit sources maintainers;};
  graphify = pkgs.python3Packages.callPackage ./graphify.nix {inherit sources maintainers;};
  rea = pkgs.callPackage ./rea.nix {inherit maintainers sources rea-wabt rea-sigrok-cli rea-pwndbg rea-pwntools-python kuna wakaru jadx-headless-mcp;};
  rea-wabt = pkgs.callPackage ./rea-wabt.nix {};
  rea-sigrok-cli = pkgs.callPackage ./rea-sigrok-cli.nix {};
  rea-pwntools-python = pkgs.callPackage ./rea-pwntools-python.nix {};
  rea-pwndbg = pkgs.callPackage ./rea-pwndbg.nix {inherit maintainers;};
  kuna = pkgs.callPackage ./kuna.nix {inherit maintainers;};
  wakaru = pkgs.callPackage ./wakaru.nix {inherit maintainers;};
  jadx-headless-mcp = pkgs.callPackage ./jadx-headless-mcp.nix {inherit maintainers;};
  tersio = pkgs.callPackage ./tersio.nix {inherit sources maintainers;};
  symposium = pkgs.callPackage ./symposium.nix {inherit sources maintainers;};
  symposium-rust-analyzer = pkgs.callPackage ./symposium-rust-analyzer.nix {inherit sources maintainers;};
  seanime-denshi = pkgs.callPackage ./seanime-denshi.nix {inherit sources maintainers;};

  vimPlugins = pkgs.vimPlugins // import ./vim-plugins {inherit pkgs sources maintainers;};
}
