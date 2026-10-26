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

    packages = forAllSystems (system:
      nixpkgs.lib.filterAttrs (_: nixpkgs.lib.isDerivation)
      (import ./packages {
        pkgs = pkgsFor system;
        inherit maintainers;
      }));

    # nested sets (vimPlugins) are invalid under `packages`; scripts/ and CI use this to reach them
    legacyPackages = forAllSystems (system: let
      pkgs = pkgsFor system;
    in
      self.packages.${system}
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
      (self.packages.${system}
        // {inherit (self.legacyPackages.${system}.vimPlugins) cord-nvim;}));
  };
}
