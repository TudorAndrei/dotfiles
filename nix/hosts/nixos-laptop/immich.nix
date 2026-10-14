{ immichPackage, ... }:
{
  # Keep the photo library on its own 200 GiB thin volume. The existing
  # media-data volume belongs to the Incus media container.
  fileSystems."/var/lib/immich" = {
    device = "/dev/default/immich-data";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };

  services.immich = {
    enable = true;
    package = immichPackage;
    # Bind only to this node's Tailscale address, never to LAN or wildcard.
    host = "100.121.29.45";
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
