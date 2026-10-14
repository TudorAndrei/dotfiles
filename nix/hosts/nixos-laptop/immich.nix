{ config, immichPackage, ... }:
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
    host = "127.0.0.1";
    openFirewall = false;
  };

  # A missing volume must stop Immich rather than put photos on the root disk.
  systemd.services.immich-server = {
    unitConfig.RequiresMountsFor = "/var/lib/immich";
    unitConfig.AssertPathIsMountPoint = "/var/lib/immich";
  };

  # Tailscale Serve terminates HTTPS within the tailnet. The Immich process
  # has no LAN listener and the public Caddy gateway has no Immich route.
  systemd.services.immich-tailnet = {
    description = "Publish Immich inside the Tailscale network";
    wantedBy = [ "multi-user.target" ];
    requires = [ "tailscaled.service" "immich-server.service" ];
    after = [ "tailscaled.service" "immich-server.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${config.services.tailscale.package}/bin/tailscale serve --bg --yes --https=9444 http://127.0.0.1:2283";
      ExecStop = "${config.services.tailscale.package}/bin/tailscale serve --https=9444 off";
    };
  };
}
