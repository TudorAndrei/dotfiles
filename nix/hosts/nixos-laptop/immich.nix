{ immichPackage, pkgs, ... }:
{
  # Keep the photo library on its own 200 GiB thin volume. The existing
  # media-data volume belongs to the Incus media container.
  systemd.services.immich-storage = {
    description = "Create the Immich thin volume";
    wantedBy = [ "var-lib-immich.mount" ];
    before = [ "var-lib-immich.mount" ];
    unitConfig.DefaultDependencies = false;
    path = [ pkgs.lvm2 pkgs.e2fsprogs ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if ! lvs default/immich-data >/dev/null 2>&1; then
        lvcreate --virtualsize 200G --thinpool default/IncusThinPool --name immich-data
        mkfs.ext4 -L immich-data /dev/default/immich-data
      fi
    '';
  };
  fileSystems."/var/lib/immich" = {
    device = "/dev/default/immich-data";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };

  services.immich = {
    enable = true;
    package = immichPackage;
    host = "0.0.0.0";
    openFirewall = false;
  };

  # A missing volume must stop Immich rather than put photos on the root disk.
  systemd.services.immich-server = {
    wants = [ "tailscaled.service" ];
    after = [ "tailscaled.service" ];
    unitConfig.RequiresMountsFor = "/var/lib/immich";
    unitConfig.AssertPathIsMountPoint = "/var/lib/immich";
    serviceConfig.StateDirectoryMode = "0700";
  };

}
