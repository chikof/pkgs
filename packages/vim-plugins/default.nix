{
  pkgs,
  sources,
  maintainers,
}: {
  cord-nvim = pkgs.callPackage ./cord-nvim.nix {inherit sources maintainers;};
}
