{ pkgs, lib, ... }:
let
  seedstrem = pkgs.callPackage ../pkgs/seedstrem { };
  root = "/srv/media";
  state = "${root}/config";
  downloads = "${root}/downloads";
  qbittorrentHome = "${state}/qbittorrent";
in
{
  networking.hostName = "media";
  networking.hosts."127.0.0.1" = [ "qbittorrent" "prowlarr" ];
  environment.etc."mime.types".source = "${pkgs.mailcap}/etc/mime.types";

  systemd.tmpfiles.rules = [
    "z ${state} 0711 root root -"
    "Z ${state}/prowlarr - media media -"
  ];

  users.groups.media.gid = 1000;
  users.users.media = {
    uid = 1000;
    group = "media";
    isSystemUser = true;
  };

  services.qbittorrent = {
    enable = true;
    user = "media";
    group = "media";
    webuiPort = 8080;
    torrentingPort = 6881;
  };
  systemd.services.qbittorrent = {
    environment = {
      HOME = qbittorrentHome;
      XDG_CONFIG_HOME = qbittorrentHome;
      XDG_DATA_HOME = qbittorrentHome;
      XDG_CACHE_HOME = "${qbittorrentHome}/.cache";
    };
    serviceConfig = {
      ExecStart = lib.mkForce "${lib.getExe pkgs.qbittorrent-nox} --webui-port=8080 --torrenting-port=6881";
      BindPaths = [ "${downloads}:/downloads" ];
    };
    unitConfig.RequiresMountsFor = [ root ];
  };

  services.prowlarr.enable = true;
  systemd.services.prowlarr = {
    unitConfig.RequiresMountsFor = [ root ];
    serviceConfig = {
      DynamicUser = lib.mkForce false;
      User = "media";
      Group = "media";
      StateDirectory = lib.mkForce "";
      ExecStart = lib.mkForce "${lib.getExe pkgs.prowlarr} -nobrowser -data=${state}/prowlarr";
    };
  };

  systemd.services.seedstrem = {
    description = "Seedstrem Stremio addon";
    wants = [ "network-online.target" "qbittorrent.service" "prowlarr.service" ];
    after = [ "network-online.target" "qbittorrent.service" "prowlarr.service" ];
    wantedBy = [ "multi-user.target" ];
    environment = {
      SEEDSTREM_SERVER_LISTEN = "127.0.0.1:8081";
      SEEDSTREM_STORAGE_DATABASE = "/config/seedstrem.db";
    };
    unitConfig.RequiresMountsFor = [ root ];
    serviceConfig = {
      User = "media";
      Group = "media";
      ExecStart = "${lib.getExe seedstrem} --config=/config/config.yaml";
      BindPaths = [ "${state}/seedstrem:/config" "${downloads}:/data" ];
      Restart = "always";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "full";
      ProtectHome = true;
    };
  };

  systemd.services.media-gateway-token = {
    description = "Render the public gateway token for nginx";
    before = [ "nginx.service" ];
    requiredBy = [ "nginx.service" ];
    unitConfig.RequiresMountsFor = [ root ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      RuntimeDirectory = "media-gateway";
    };
    script = ''
      token=$(${lib.getExe pkgs.jq} -er .public_token ${state}/credentials.json)
      install -m 0640 -g nginx /dev/null /run/media-gateway/token.conf
      printf 'set $public_token "%s";\n' "$token" > /run/media-gateway/token.conf
    '';
  };

  services.nginx = {
    enable = true;
    validateConfigFile = false;
    virtualHosts.gateway = {
      default = true;
      listen = [ { addr = "127.0.0.1"; port = 8082; } ];
      extraConfig = ''
        include /run/media-gateway/token.conf;
        access_log off;
        add_header Access-Control-Allow-Origin '*' always;
        add_header Access-Control-Allow-Methods 'GET, HEAD, OPTIONS' always;
        add_header Access-Control-Allow-Headers 'Range, Content-Type' always;
        add_header Referrer-Policy 'no-referrer' always;
        proxy_http_version 1.1;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Proto https;
        proxy_buffering off;
        proxy_request_buffering off;
        proxy_read_timeout 300s;
        proxy_hide_header Access-Control-Allow-Origin;
        proxy_hide_header Access-Control-Allow-Headers;
      '';
      locations."~ ^/(?<token>[^/]+)/(stremio|dl)/".extraConfig = ''
        if ($token != $public_token) { return 404; }
        if ($request_method = OPTIONS) { return 204; }
        limit_except GET HEAD { deny all; }
        rewrite ^/[^/]+(/.*)$ $1 break;
        proxy_pass http://127.0.0.1:8081;
      '';
      locations."/".return = "404";
    };
  };
}
