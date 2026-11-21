{ pkgs, lib, ... }:
let
  tailnetHost = "100.121.29.45";
  pcHost = "100.70.0.10";
  poolMetricsPort = 8186;
in
{
  services.homepage-dashboard = {
    enable = true;
    listenPort = 8083;
    openFirewall = false;
    allowedHosts = "${tailnetHost}:8083,localhost:8083,127.0.0.1:8083";
    settings = {
      title = "NixOS laptop";
      theme = "dark";
      statusStyle = "dot";
    };
    widgets = [
      { resources = { label = "Laptop"; cpu = true; memory = true; uptime = true; }; }
      { resources = { label = "Root disk"; disk = "/"; }; }
      { resources = { label = "Immich disk"; disk = "/var/lib/immich"; }; }
      { resources = { label = "Music disk"; disk = "/srv/music"; }; }
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
        PC = [
          {
            ComfyUI = {
              icon = "comfyui.png";
              description = "Runs on the PC in WSL";
              href = "http://${pcHost}:8188/";
              widget = {
                type = "iframe";
                name = "pc-switches";
                src = "http://${pcHost}:8187/";
                classes = "h-24";
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
              href = "http://${tailnetHost}:2283/";
              siteMonitor = "http://127.0.0.1:2283/";
            };
          }
        ];
      }
      {
        Network = [
          {
            "Internet (Pi, cable)" = {
              icon = "mdi-speedometer";
              description = "Mbit/s and ms, every 3 hours";
              href = "http://100.73.26.126:8090/";
              widget = {
                type = "customapi";
                url = "http://192.168.0.233:8090/latest.json";
                refreshInterval = 300000;
                mappings = [
                  { field = "download.bandwidth"; label = "Down"; format = "number"; scale = "8/1000000"; }
                  { field = "upload.bandwidth"; label = "Up"; format = "number"; scale = "8/1000000"; }
                  { field = "ping.latency"; label = "Ping"; format = "number"; }
                  { field = "timestamp"; label = "Tested"; format = "relativeDate"; style = "narrow"; numeric = "auto"; }
                ];
              };
            };
          }
        ];
      }
      {
        Media = [
          {
            Navidrome = {
              icon = "navidrome.png";
              href = "http://${tailnetHost}:4533/";
              siteMonitor = "http://127.0.0.1:4533/";
            };
          }
          {
            "Music Assistant" = {
              icon = "music-assistant.png";
              description = "100.121.29.45:8095";
              href = "http://${tailnetHost}:8095/";
              siteMonitor = "http://127.0.0.1:8095/";
            };
          }
          {
            Syncthing = {
              icon = "syncthing.png";
              description = "100.121.29.45:8384";
              href = "http://${tailnetHost}:8384/";
              siteMonitor = "http://127.0.0.1:8384/";
            };
          }
          {
            Seedstrem = {
              icon = "mdi-play-circle";
              href = "http://${tailnetHost}:8081/";
              siteMonitor = "http://127.0.0.1:8081/";
            };
          }
          {
            AIOStreams = {
              icon = "mdi-layers-triple";
              href = "http://${tailnetHost}:3000/";
              siteMonitor = "http://127.0.0.1:3000/";
            };
          }
          {
            Prowlarr = {
              icon = "prowlarr.png";
              href = "http://${tailnetHost}:9696/";
              siteMonitor = "http://127.0.0.1:9696/";
            };
          }
          {
            qBittorrent = {
              icon = "qbittorrent.png";
              href = "http://${tailnetHost}:8080/";
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
              href = "http://${tailnetHost}:8318/management.html";
              siteMonitor = "http://127.0.0.1:8318/management.html";
            };
          }
          {
            "T3 Code" = {
              icon = "mdi-robot";
              href = "http://${tailnetHost}:3773/";
              siteMonitor = "http://127.0.0.1:3773/";
            };
          }
        ];
      }
    ];
  };

  # The firewall opens this listener only on tailscale0. The public Caddy site has no route.
  systemd.services.homepage-dashboard.environment.HOSTNAME = "0.0.0.0";

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
