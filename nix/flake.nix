{
  description = "Tudor's Ubuntu/WSL environment and NixOS/Lix homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-immich.url = "github:NixOS/nixpkgs/master";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs-stable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-stable.url = "github:nix-community/home-manager/release-26.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixpkgs-immich, nixos-hardware, home-manager, home-manager-stable, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    desktopHome = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home.nix ];
    };
    guest = name: nixpkgs-stable.lib.nixosSystem {
      inherit system;
      specialArgs.unstable = nixpkgs.legacyPackages.${system};
      modules = [ ./guests/common.nix (./guests + "/${name}.nix") ];
    };
  in {
    packages.${system} = {
      nh = pkgs.nh;
      seedstrem = pkgs.callPackage ./pkgs/seedstrem { };
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
      specialArgs.immichPackage = nixpkgs-immich.legacyPackages.${system}.immich;
      specialArgs.tailscalePackage = nixpkgs.legacyPackages.${system}.tailscale;
      specialArgs.unstable = nixpkgs.legacyPackages.${system};
      specialArgs.guests = { inherit (self.nixosConfigurations) media cliproxy; };
      modules = [
        # No exact MSI Raider GE66 12UGS profile exists upstream.
        nixos-hardware.nixosModules.common-cpu-intel-cpu-only
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-ssd
        "${nixos-hardware}/common/gpu/nvidia/ampere"
        home-manager-stable.nixosModules.home-manager
        ./hosts/nixos-laptop/configuration.nix
        ./hosts/nixos-laptop/hardware-configuration.nix
      ];
    };
    nixosConfigurations.media = guest "media";
    nixosConfigurations.cliproxy = guest "cliproxy";
  };
}
