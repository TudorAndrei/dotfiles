{
  description = "Tudor's user environment for Ubuntu with Lix and NH";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.${system} = {
      nh = pkgs.nh;
      default = pkgs.buildEnv {
        name = "tudor-packages";
        paths = import ./packages.nix { inherit pkgs; };
        pathsToLink = [ "/bin" ];
      };
    };
    homeConfigurations.tudor = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
    };
  };
}
