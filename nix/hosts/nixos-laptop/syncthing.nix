{
  services.syncthing = {
    enable = true;
    user = "tudor";
    group = "users";
    dataDir = "/home/tudor";
    configDir = "/home/tudor/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";
    overrideDevices = true;
    overrideFolders = true;
    settings = {
      options.urAccepted = -1;
      devices.piticu.id = "WTU327G-CHSY2OO-6IVR6M5-5GDBRHV-H2EXCON-XEP4F7Q-LORCPQL-FE5FEAT";
      folders.music = {
        id = "sokpe-mf6hm";
        label = "Music";
        path = "/srv/music";
        type = "receiveonly";
        devices = [ "piticu" ];
      };
    };
  };

  systemd.services.syncthing.unitConfig.RequiresMountsFor = [ "/srv/music" ];
}
