{
  description = "monomara's NixOS config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, home-manager, ... }: {
    nixosConfigurations = {
      spirit = nixpkgs.lib.nixosSystem {
         system = "x86_64-linux";
         modules = [
           ./configuration.nix
           home-manager.nixosModules.home-manager
           {
             nix.registry.nixpkgs.flake = nixpkgs;
             nix.nixPath = ["nixpkgs=flake:nixpkgs"];
             home-manager.useGlobalPkgs = true;
             home-manager.useUserPackages = true;
             home-manager.users.monomara = import ./home.nix;
           }
         ];
       };
    };
  };
}
