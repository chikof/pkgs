{
  pkgs,
  maintainers,
}: let
  sources = pkgs.callPackage ../_sources/generated.nix {};
in {
  equibop = pkgs.callPackage ./equibop.nix {inherit sources maintainers;};
}
