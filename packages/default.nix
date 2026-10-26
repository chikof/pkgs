{
  pkgs,
  maintainers,
}: rec {
  equibop = pkgs.callPackage ./equibop.nix {inherit maintainers;};
  unfetch = pkgs.callPackage ./unfetch.nix {inherit maintainers;};
  g = pkgs.callPackage ./g.nix {inherit maintainers;};
  nano-ffmpeg = pkgs.callPackage ./nano-ffmpeg.nix {inherit maintainers;};
  cavemem = pkgs.callPackage ./cavemem.nix {inherit maintainers;};
  typescript-svelte-plugin = pkgs.callPackage ./typescript-svelte-plugin.nix {inherit maintainers;};
  fallow = pkgs.callPackage ./fallow.nix {inherit maintainers;};
  grompt = pkgs.callPackage ./grompt.nix {inherit maintainers;};
  graphify = pkgs.python3Packages.callPackage ./graphify.nix {inherit maintainers;};
  rea = pkgs.callPackage ./rea.nix {inherit maintainers rea-wabt rea-sigrok-cli rea-pwndbg rea-pwntools-python kuna wakaru jadx-headless-mcp;};
  rea-wabt = pkgs.callPackage ./rea-wabt.nix {};
  rea-sigrok-cli = pkgs.callPackage ./rea-sigrok-cli.nix {};
  rea-pwntools-python = pkgs.callPackage ./rea-pwntools-python.nix {};
  rea-pwndbg = pkgs.callPackage ./rea-pwndbg.nix {inherit maintainers;};
  kuna = pkgs.callPackage ./kuna.nix {inherit maintainers;};
  wakaru = pkgs.callPackage ./wakaru.nix {inherit maintainers;};
  jadx-headless-mcp = pkgs.callPackage ./jadx-headless-mcp.nix {inherit maintainers;};
  tersio = pkgs.callPackage ./tersio.nix {inherit maintainers;};
  symposium = pkgs.callPackage ./symposium.nix {inherit maintainers;};
  symposium-rust-analyzer = pkgs.callPackage ./symposium-rust-analyzer.nix {inherit maintainers;};
  seanime-denshi = pkgs.callPackage ./seanime-denshi.nix {inherit maintainers;};

  vimPlugins = pkgs.vimPlugins // import ./vim-plugins {inherit pkgs maintainers;};
}
