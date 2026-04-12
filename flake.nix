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
    in
      import ./packages {inherit pkgs maintainers;});

    overlays.default = final: prev:
      import ./packages {pkgs = prev; inherit maintainers;};

    formatter = forAllSystems (system: (pkgsFor system).alejandra);

    devShells = forAllSystems (system: let
      pkgs = pkgsFor system;
    in {
      default = pkgs.mkShell {
        packages = with pkgs; [
          alejandra
          nix-update
          nix-prefetch
          nix-prefetch-github
          nvfetcher
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
