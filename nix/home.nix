{ pkgs, ... }:
{
  home.username = "tudor";
  home.homeDirectory = "/home/tudor";
  home.stateVersion = "26.05";
  home.packages = import ./packages.nix { inherit pkgs; };
  home.sessionVariables = {
    NH_HOME_FLAKE = "/home/tudor/dotfiles/nix";
    NH_OS_FLAKE = "/home/tudor/dotfiles/nix/hosts/nixos-laptop";
  };
}
