# Every <name>/package.nix is a top-level attr; vim-plugins/ merges into vimPlugins instead.
{
  pkgs,
  maintainers,
}: let
  inherit (pkgs) lib;
  # packages that are not plain pkgs.callPackage
  scope = {
    graphify = pkgs.python3Packages;
    headroom = pkgs.python3Packages;
    mcp-for-blender = pkgs.python3Packages;
  };
  # sibling packages a package takes as arguments
  siblings = {
    rea = {inherit (self) rea-wabt rea-sigrok-cli rea-pwndbg rea-pwntools-python kuna wakaru jadx-headless-mcp;};
    blender-mcp = {inherit (self) mcp-for-blender;};
  };
  names = builtins.attrNames (lib.filterAttrs (n: t: t == "directory" && builtins.pathExists (./. + "/${n}/package.nix")) (builtins.readDir ./.));
  self =
    lib.genAttrs names (n:
      ((scope.${n} or pkgs).newScope {inherit maintainers;}) (./. + "/${n}/package.nix") (siblings.${n} or {}))
    // {vimPlugins = pkgs.vimPlugins // import ./vim-plugins {inherit pkgs maintainers;};};
in
  self
