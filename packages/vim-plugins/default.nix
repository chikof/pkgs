{
  pkgs,
  maintainers,
}: {
  cord-nvim = pkgs.callPackage ./cord-nvim.nix {inherit maintainers;};
  duvet-nvim = pkgs.callPackage ./duvet-nvim.nix {inherit maintainers;};
}
