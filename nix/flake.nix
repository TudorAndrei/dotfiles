{
  description = "Tudor's Ubuntu/WSL environment and NixOS/Lix homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixos-hardware.inputs.nixpkgs.follows = "nixpkgs-stable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-stable.url = "github:nix-community/home-manager/release-26.05";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
    rex.url = "https://pkgs.superlogical.com/rex/nix/snapshot.tar.gz";
    rex.inputs.nixpkgs.follows = "nixpkgs";
    hermes-agent.url = "github:NousResearch/hermes-agent/v0.22.5";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, nixos-hardware, home-manager, home-manager-stable, ... }@inputs: let
    system = "x86_64-linux";
    unstable = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
        android_sdk.accept_license = true;
      };
    };
    desktopHome = home-manager.lib.homeManagerConfiguration {
      pkgs = unstable;
      extraSpecialArgs = { inherit unstable; };
      modules = [ ./home.nix ];
    };
    guest = name: nixpkgs-stable.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit unstable inputs; };
      modules = [ ./guests/common.nix (./guests + "/${name}.nix") ];
    };
  in {
    packages.${system} = {
      inherit (unstable) nh;
      seedstrem = unstable.callPackage ./pkgs/seedstrem { };
      default = unstable.buildEnv {
        name = "tudor-packages";
        paths = import ./packages.nix { pkgs = unstable; };
        pathsToLink = [ "/bin" ];
      };
    };
    formatter.${system} = unstable.nixfmt;
    checks.${system}.lint = unstable.runCommand "nix-lint" {
      nativeBuildInputs = [ unstable.statix unstable.deadnix ];
    } ''
      statix check ${./.}
      deadnix --fail ${./.}
      touch $out
    '';
    homeConfigurations = {
      "tudor@parnaie" = desktopHome;
      # Preserve existing NH invocations while naming the desktop explicitly.
      tudor = desktopHome;
    };
    nixosConfigurations = {
      nixos-laptop =nixpkgs-stable.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit unstable inputs; guests = { inherit (self.nixosConfigurations) media cliproxy hermes; }; };
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
      media = guest "media";
      cliproxy = guest "cliproxy";
      hermes = guest "hermes";
    };
  };
}
