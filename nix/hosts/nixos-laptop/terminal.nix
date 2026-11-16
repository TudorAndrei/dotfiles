{ pkgs, unstable, inputs, ... }:
{
  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;
  users.users.tudor.shell = pkgs.zsh;
  environment.sessionVariables = {
    AGENT_BROWSER_EXECUTABLE_PATH = "${unstable.chromium}/bin/chromium";
    PKG_CONFIG_PATH = "${unstable.openssl.dev}/lib/pkgconfig";
    MISE_RUBY_COMPILE = "false";
  };

  systemd.tmpfiles.rules = [
    "d /home/tudor/.local/state/zsh 0700 tudor users -"
    "d /home/tudor/.local/share/zsh 0700 tudor users -"
  ];

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit unstable; };
    backupFileExtension = "hm-backup";
    users.tudor = {
      imports = [ ../../home.nix inputs.rex.homeManagerModules.default ];
      programs.rex.sshGuard = false;
      services.rex = {
        enable = true;
        extraListen = [ "tailnet://:7297" ];
        extraArgs = [ "--tailnet-allow-identified" ];
      };
      manual.manpages.enable = false;
    };
  };



}
