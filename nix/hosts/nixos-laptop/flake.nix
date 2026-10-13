{
  description = "Headless NixOS/Lix Incus homelab laptop";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { nixpkgs, nixos-hardware, ... }: {
    nixosConfigurations.nixos-laptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # No exact MSI Raider GE66 12UGS profile exists upstream.
        nixos-hardware.nixosModules.common-cpu-intel-cpu-only
        nixos-hardware.nixosModules.common-pc-laptop
        nixos-hardware.nixosModules.common-pc-ssd
        "${nixos-hardware}/common/gpu/nvidia/ampere"
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
  };
}
