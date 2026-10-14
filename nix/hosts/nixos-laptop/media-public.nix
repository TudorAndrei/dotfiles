{ ... }:
{
  # Digi DDNS tracks the home connection. The router must forward TCP 80/443
  # to this reserved laptop LAN address. Only the keyed streaming gateway
  # is exposed; administration remains on private Tailscale listeners.
  networking.firewall.allowedTCPPorts = [ 80 443 ];
  services.caddy = {
    enable = true;
    virtualHosts."casapuiu.home.ro" = {
      listenAddresses = [ "192.168.0.244" ];
      # The URL carries the access key; do not log request URLs.
      logFormat = null;
      extraConfig = "reverse_proxy 127.0.0.1:8082";
    };
  };
}
