{
  pkgs,
  maintainers,
}: {
  cord-nvim = pkgs.callPackage ./cord-nvim.nix {inherit maintainers;};
}
