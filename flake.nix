{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }:
    let
      allSystems = {
        x86_64-linux = { };
        aarch64-linux = { };
      };
      # Helper function to generate a set of attributes for each system
      forAllSystems = func: (nixpkgs.lib.genAttrs (builtins.attrNames allSystems) func);
    in
    {
      # Packages
      packages = forAllSystems (
        system: allSystems.${system}.packages or { }
      );

      nixosConfigurations = {
        hetzner-base = forAllSystems (system: nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./configuration.nix
            inputs.disko.nixosModules.disko
          ];
        });
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [ just ];
          };
        }
      );

      formatter = forAllSystems (
        system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt
      );
    };
}
