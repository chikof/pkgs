{
  description = "My custom nix packages";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  }: let
    forAllSystems = nixpkgs.lib.genAttrs (import systems);
    pkgsFor = system: nixpkgs.legacyPackages.${system};
    maintainers = import ./lib/maintainers.nix;
  in {
    lib = {inherit maintainers;};

    packages = forAllSystems (system: let
      pkgs = pkgsFor system;
      pkgSet = import ./packages {inherit pkgs maintainers;};
    in
      nixpkgs.lib.mapAttrs (
        name: value:
          if nixpkgs.lib.isDerivation value
          then value
          else removeAttrs value (builtins.attrNames (pkgs.${name} or {}))
      )
      pkgSet);

    # full package set incl. our vimPlugins (nested sets are invalid under `packages`); used by scripts/ and CI
    legacyPackages = forAllSystems (system: let
      pkgs = pkgsFor system;
    in
      (import ./packages {inherit pkgs maintainers;})
      // {vimPlugins = import ./packages/vim-plugins {inherit pkgs maintainers;};});

    overlays.default = final: prev:
      import ./packages {
        pkgs = prev;
        inherit maintainers;
      };

    formatter = forAllSystems (system: (pkgsFor system).alejandra);

    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          jq
          nix-update
          nodejs
        ];
      };
    });

    checks = forAllSystems (system:
      nixpkgs.lib.mapAttrs' (name: pkg:
        nixpkgs.lib.nameValuePair "package-${name}" pkg)
      (nixpkgs.lib.filterAttrs (n: _: n != "default")
        self.packages.${system}));
  };
}
