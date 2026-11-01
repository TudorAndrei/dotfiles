{ lib, pkgs, ... }:
let
  music = "/srv/music";
in
{
  systemd.services.music-storage = {
    description = "Create the music thin volume";
    wantedBy = [ "srv-music.mount" ];
    before = [ "srv-music.mount" ];
    unitConfig.DefaultDependencies = false;
    path = [ pkgs.lvm2 pkgs.e2fsprogs ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if ! lvs default/music-data >/dev/null 2>&1; then
        lvcreate --virtualsize 150G --thinpool default/IncusThinPool --name music-data
        mkfs.ext4 -L music-data /dev/default/music-data
      fi
    '';
  };
  fileSystems.${music} = {
    device = "/dev/default/music-data";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };

  services.navidrome = {
    enable = true;
    openFirewall = false;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = music;
    };
  };

  systemd.tmpfiles.settings.navidromeDirs.${music}.d = lib.mkForce {
    mode = "0755";
    user = "tudor";
    group = "users";
  };

  systemd.services.navidrome = {
    wants = [ "tailscaled.service" ];
    after = [ "tailscaled.service" ];
    unitConfig.RequiresMountsFor = music;
    unitConfig.AssertPathIsMountPoint = music;
  };
}
