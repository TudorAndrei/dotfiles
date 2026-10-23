{ pkgs, lib, ... }:
let
  tailnetHost = "nixos-laptop.tail582219.ts.net";
  poolMetricsPort = 8186;
in
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8083;
    openFirewall = false;
    allowedHosts = "${tailnetHost}:8446,localhost:8083,127.0.0.1:8083";
    settings = {
      title = "NixOS laptop";
      theme = "dark";
      statusStyle = "dot";
    };
    widgets = [
      { resources = { label = "Laptop"; cpu = true; memory = true; uptime = true; }; }
      { resources = { label = "Root disk"; disk = "/"; }; }
      { resources = { label = "Immich disk"; disk = "/var/lib/immich"; }; }
    ];
    services = [
      {
        System = [
          {
            "Incus thin pool" = {
              icon = "mdi-harddisk";
              description = "Shared Incus and Immich storage";
              widget = {
                type = "customapi";
                url = "http://127.0.0.1:${toString poolMetricsPort}/pool";
                refreshInterval = 60000;
                mappings = [
                  { field = "data_percent"; label = "Data"; format = "percent"; }
                  { field = "metadata_percent"; label = "Metadata"; format = "percent"; }
                ];
              };
            };
          }
        ];
      }
      {
        Photos = [
          {
            Immich = {
              icon = "immich.png";
              href = "http://100.121.29.45:2283/";
              siteMonitor = "http://127.0.0.1:2283/";
            };
          }
        ];
      }
      {
        Media = [
          {
            Seedstrem = {
              icon = "mdi-play-circle";
              href = "https://${tailnetHost}:9443/";
              siteMonitor = "http://127.0.0.1:8081/";
            };
          }
          {
            Prowlarr = {
              icon = "prowlarr.png";
              href = "https://${tailnetHost}:8443/";
              siteMonitor = "http://127.0.0.1:9696/";
            };
          }
          {
            qBittorrent = {
              icon = "qbittorrent.png";
              href = "https://${tailnetHost}:8444/";
              siteMonitor = "http://127.0.0.1:8080/";
            };
          }
        ];
      }
      {
        Tools = [
          {
            CLIProxyAPI = {
              icon = "mdi-api";
              href = "https://${tailnetHost}:8445/management.html";
              siteMonitor = "http://127.0.0.1:8318/management.html";
            };
          }
          {
            "T3 Code" = {
              icon = "mdi-robot";
              href = "https://${tailnetHost}:8447/";
              siteMonitor = "http://127.0.0.1:3773/";
            };
          }
        ];
      }
    ];
  };

  # Serve can reach this loopback listener. The public Caddy site has no route.
  systemd.services.homepage-dashboard.environment.HOSTNAME = "127.0.0.1";

  # Only Homepage can query this loopback endpoint. It runs lvs without a shell.
  systemd.services.homepage-pool-metrics = {
    description = "Read Incus thin pool use for Homepage";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 ${./pool-metrics.py} ${lib.getBin pkgs.lvm2}/bin/lvs ${toString poolMetricsPort}";
      Restart = "on-failure";
      NoNewPrivileges = true;
      ProtectSystem = "strict";
      ReadWritePaths = [ "/run/lock/lvm" ];
      ProtectHome = true;
      PrivateTmp = true;
      RestrictAddressFamilies = [ "AF_INET" "AF_UNIX" ];
    };
  };
}
