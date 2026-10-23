{ modulesPath, ... }:
{
  imports = [ "${modulesPath}/virtualisation/lxc-container.nix" ];

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };
  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig.DHCP = "ipv4";
      linkConfig.RequiredForOnline = "routable";
    };
  };

  time.timeZone = "Europe/Bucharest";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  services.journald.extraConfig = "SystemMaxUse=256M";
  system.stateVersion = "26.05";
}
