{
  description = "Tudor's Ubuntu/WSL environment and NixOS/Lix homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs-stable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, nixpkgs-stable, nixos-hardware, home-manager, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    desktopHome = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
    };
  in {
    packages.${system} = {
      nh = pkgs.nh;
      default = pkgs.buildEnv {
        name = "tudor-packages";
        paths = import ./packages.nix { inherit pkgs; };
        pathsToLink = [ "/bin" ];
      };
    };
    homeConfigurations = {
      "tudor@parnaie" = desktopHome;
      # Preserve existing NH invocations while naming the desktop explicitly.
      tudor = desktopHome;
    };
    nixosConfigurations.nixos-laptop = nixpkgs-stable.lib.nixosSystem {
      inherit system;
      specialArgs.immichPackage = nixpkgs.legacyPackages.${system}.immich;
      specialArgs.tailscalePackage = nixpkgs.legacyPackages.${system}.tailscale;
      modules = [
        # No exact MSI Raider GE66 12UGS profile exists upstream.
        nixos-hardware.nixosModules.common-cpu-intel-cpu-only
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-ssd
        "${nixos-hardware}/common/gpu/nvidia/ampere"
        ./hosts/nixos-laptop/configuration.nix
        ./hosts/nixos-laptop/hardware-configuration.nix
      ];
    };
  };
}
