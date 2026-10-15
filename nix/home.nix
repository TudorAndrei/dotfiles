{ config, lib, pkgs, ... }:
let
  pluginInstallPath = lib.makeBinPath (with pkgs; [
    herdr git bash curl gnutar gzip unzip cargo rustc stdenv.cc pkg-config
  ]);
in
{
  home.username = "tudor";
  home.homeDirectory = "/home/tudor";
  home.stateVersion = "26.05";
  home.packages = import ./packages.nix { inherit pkgs; };
  xdg.configFile."herdr/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/configs/herdr/config.toml";
  xdg.configFile."herdr/plugins/config/herdr-navigator/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/configs/herdr/plugins/herdr-navigator.toml";
  xdg.configFile."herdr-automatic-rename/config.sh".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/configs/herdr/plugins/herdr-automatic-rename.sh";
  home.activation.herdrPlugins = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    PATH="${pluginInstallPath}:$PATH" run ${pkgs.bash}/bin/bash \
      "${config.home.homeDirectory}/dotfiles/configs/herdr/install-plugins.sh"
  '';
  home.sessionVariables = {
    NH_HOME_FLAKE = "/home/tudor/dotfiles/nix";
    NH_OS_FLAKE = "/home/tudor/dotfiles/nix";
  };
}
