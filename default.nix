# Non-flake entry point (nix-update, nix-build). Uses the nixpkgs pinned in flake.lock.
{system ? builtins.currentSystem}: let
  n = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
  pkgs = import (builtins.fetchTarball {
    url = "https://github.com/${n.owner}/${n.repo}/archive/${n.rev}.tar.gz";
    sha256 = n.narHash;
  }) {inherit system;};
in
  import ./packages {
    inherit pkgs;
    maintainers = import ./lib/maintainers.nix;
  }
