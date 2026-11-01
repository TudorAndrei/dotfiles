{ config, lib, pkgs, unstable, ... }:
let
  pluginInstallPath = lib.makeBinPath (with unstable; [
    herdr git bash curl gnutar gzip unzip cargo rustc stdenv.cc pkg-config
  ]);
in
{
  home = {
    username = "tudor";
    homeDirectory = "/home/tudor";
    stateVersion = "26.05";
    packages = import ./packages.nix { pkgs = unstable; };
    activation.herdrPlugins = config.lib.dag.entryAfter [ "linkGeneration" ] ''
      PATH="${pluginInstallPath}:$PATH" run ${pkgs.bash}/bin/bash \
        "${config.home.homeDirectory}/dotfiles/configs/herdr/install-plugins.sh"
    '';
    sessionVariables = {
      NH_HOME_FLAKE = "/home/tudor/dotfiles/nix";
      NH_OS_FLAKE = "/home/tudor/dotfiles/nix";
    };
  };
  xdg.configFile = {
    "herdr/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/configs/herdr/config.toml";
    "herdr/plugins/config/herdr-navigator/config.toml".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/configs/herdr/plugins/herdr-navigator.toml";
    "herdr-automatic-rename/config.sh".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/dotfiles/configs/herdr/plugins/herdr-automatic-rename.sh";
  };
}
