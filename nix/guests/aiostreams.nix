{ pkgs, ... }:
let
  state = "/srv/media/config";
  dir = "${state}/aiostreams";
  port = 3000;
  local = "http://127.0.0.1:${toString port}";

  userConfig = {
    addonName = "AIOStreams";
    services = [ ];
    presets = [
      {
        type = "torrentio";
        instanceId = "torrentio";
        enabled = true;
        options = {
          name = "Torrentio";
          timeout = 10000;
          useMultipleInstances = false;
          services = [ ];
        };
      }
      {
        type = "custom";
        instanceId = "seedstrem";
        enabled = true;
        options = {
          name = "Seedstrem";
          timeout = 10000;
          manifestUrl = "http://127.0.0.1:8081/stremio/manifest.json";
        };
      }
    ];
    excludedQualities = [ "CAM" "TS" "TC" "SCR" ];
    excludedResolutions = [ "576p" "480p" "360p" "240p" "144p" ];
    preferredResolutions = [ "2160p" "1440p" "1080p" "720p" "Unknown" ];
    preferredQualities = [ "BluRay REMUX" "BluRay" "WEB-DL" "WEBRip" "HDRip" "HC HD-Rip" "DVD REMUX" "DVDRip" "HDTV" "Unknown" ];
    formatter.id = "torrentio";
    sortCriteria.global = [
      { key = "resolution"; direction = "desc"; }
      { key = "quality"; direction = "desc"; }
      { key = "seeders"; direction = "desc"; }
      { key = "size"; direction = "desc"; }
    ];
  };
  configFile = pkgs.writeText "aiostreams-config.json" (builtins.toJSON userConfig);
in
{
  systemd = {
    tmpfiles.rules = [ "d ${dir} 0700 media media -" ];
    services = {
      aiostreams-env = {
        description = "Render AIOStreams secrets and public base URL";
        before = [ "podman-aiostreams.service" ];
        requiredBy = [ "podman-aiostreams.service" ];
        partOf = [ "podman-aiostreams.service" ];
        unitConfig.RequiresMountsFor = [ state ];
        path = [ pkgs.jq pkgs.openssl ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          RuntimeDirectory = "aiostreams";
          RuntimeDirectoryMode = "0700";
          RuntimeDirectoryPreserve = true;
          UMask = "0077";
        };
        script = ''
          [ -s ${dir}/secret_key ] || openssl rand -hex 32 > ${dir}/secret_key
          [ -s ${dir}/password ] || openssl rand -hex 24 > ${dir}/password
          base=$(jq -er '.public_manifest_url | sub("/stremio/manifest.json$"; "")' ${state}/credentials.json)/aio
          printf '%s\n' "$base" > ${dir}/base_url
          chown media:media ${dir}/secret_key ${dir}/password ${dir}/base_url
          printf 'SECRET_KEY=%s\nBASE_URL=%s\n' "$(cat ${dir}/secret_key)" "$base" > /run/aiostreams/env
        '';
      };
      podman-aiostreams.unitConfig.RequiresMountsFor = [ state ];
      aiostreams-config = {
        description = "Apply the declared AIOStreams user config";
        wants = [ "seedstrem.service" ];
        after = [ "podman-aiostreams.service" "seedstrem.service" ];
        requires = [ "podman-aiostreams.service" ];
        wantedBy = [ "multi-user.target" ];
        restartTriggers = [ configFile ];
        path = [ pkgs.curl pkgs.jq pkgs.coreutils ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = "media";
          Group = "media";
          UMask = "0077";
          RuntimeDirectory = "aiostreams-config";
        };
        script = ''
          for _ in $(seq 90); do
            curl -fs ${local}/api/v1/health >/dev/null && break
            sleep 2
          done
          body=$RUNTIME_DIRECTORY/body.json
          password=$(cat ${dir}/password)
          if [ ! -s ${dir}/uuid ]; then
            jq -n --slurpfile c ${configFile} --arg p "$password" '{config: $c[0], password: $p}' > "$body"
            response=$(curl -fsS -X POST -H 'Content-Type: application/json' --data @"$body" ${local}/api/v1/user)
            jq -er .data.uuid <<<"$response" > ${dir}/uuid
            jq -er .data.encryptedPassword <<<"$response" > ${dir}/encrypted_password
          else
            jq -n --slurpfile c ${configFile} '{config: $c[0]}' > "$body"
            printf 'user = "%s:%s"\n' "$(cat ${dir}/uuid)" "$password" |
              curl -fsS -K - -X PUT -H 'Content-Type: application/json' --data @"$body" ${local}/api/v1/user >/dev/null
          fi
          printf '%s/stremio/%s/%s/manifest.json\n' \
            "$(cat ${dir}/base_url)" "$(cat ${dir}/uuid)" "$(cat ${dir}/encrypted_password)" > ${dir}/manifest_url
        '';
      };
    };
  };

  virtualisation.podman.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers.aiostreams = {
      image = "ghcr.io/viren070/aiostreams:v2.37.0@sha256:bcfd8580695a50c8f464578a0e25af065f3bd17eac35ed82a733a18342ca9718";
      user = "1000:1000";
      extraOptions = [ "--network=host" ];
      volumes = [ "${dir}:/app/data" ];
      environment = {
        PORT = toString port;
        DATABASE_URI = "sqlite://./data/db.sqlite";
        LOG_FORMAT = "text";
      };
      environmentFiles = [ "/run/aiostreams/env" ];
    };
  };

  services.nginx.virtualHosts.gateway.locations."~ ^/(?<token>[^/]+)/aio/stremio/".extraConfig = ''
    if ($token != $public_token) { return 404; }
    if ($request_method = OPTIONS) { return 204; }
    limit_except GET HEAD { deny all; }
    rewrite ^/[^/]+/aio(/.*)$ $1 break;
    proxy_pass ${local};
  '';
}
