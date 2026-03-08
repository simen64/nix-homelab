{
  inputs.clan-core.url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
  inputs.nixpkgs.follows = "clan-core/nixpkgs";
  inputs.nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    clan-core,
    nixpkgs,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    # Usage see: https://docs.clan.lol
    clan = clan-core.lib.clan {
      inherit self;
      imports = [./clan.nix];
      specialArgs = {
        inherit inputs;
        outputs = self;
      };

      # Customize nixpkgs
      # pkgsForSystem =
      #   system:
      #   import nixpkgs {
      #     inherit system;
      #     config = {
      #       allowUnfree = true;
      #     };
      #     overlays = [];
      #   };
    };
  in {
    overlays = {
      unstable-packages = final: prev: {
        unstable = import nixpkgs-unstable {
          system = final.system;
          config = {
            allowUnfree = true;
          };
        };
      };
    };

    inherit (clan.config) nixosConfigurations nixosModules clanInternals;
    clan = clan.config;
    # Add the Clan cli tool to the dev shell.
    # Use "nix develop" to enter the dev shell.
    devShells =
      nixpkgs.lib.genAttrs
      [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ]
      (system: {
        default = clan-core.inputs.nixpkgs.legacyPackages.${system}.mkShell {
          packages = [clan-core.packages.${system}.clan-cli];
        };
      });
  };
}
