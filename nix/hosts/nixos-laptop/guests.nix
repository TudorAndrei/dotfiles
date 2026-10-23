{ config, lib, pkgs, guests, ... }:
let
  incus = config.virtualisation.incus.package;
  proxy = listen: connect: { type = "proxy"; inherit listen connect; };
  forward = address: port: proxy "tcp:${address}:${toString port}" "tcp:127.0.0.1:${toString port}";
  deploy = name: guest: {
    description = "Create and switch the ${name} Incus guest";
    wants = [ "incus-preseed.service" ];
    requires = [ "incus.service" ];
    after = [ "incus.service" "incus-preseed.service" ];
    wantedBy = [ "multi-user.target" ];
    path = [ incus config.nix.package pkgs.gnugrep ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      toplevel=${guest.config.system.build.toplevel}
      guest() { incus exec ${name} -- /run/current-system/sw/bin/"$@"; }
      if ! incus info ${name} >/dev/null 2>&1; then
        incus create images:nixos/26.05 ${name} --profile default --profile ${name}
      fi
      if ! incus info ${name} | grep -qx 'Status: RUNNING'; then
        incus start ${name}
      fi
      until guest true 2>/dev/null; do sleep 1; done
      if [ "$(guest readlink -f /run/current-system)" = "$toplevel" ]; then
        exit 0
      fi
      paths=$(nix-store --query --requisites "$toplevel")
      invalid=$(guest nix-store --check-validity --print-invalid $paths)
      if [ -n "$invalid" ]; then
        nix-store --export $(grep -Fx -f <(printf '%s\n' "$invalid") <<<"$paths") |
          guest nix-store --import >/dev/null
      fi
      guest nix-env --profile /nix/var/nix/profiles/system --set "$toplevel"
      incus exec ${name} -- "$toplevel/bin/switch-to-configuration" switch
    '';
  };
in
{
  virtualisation.incus.preseed = {
    storage_volumes = [
      { name = "media-data"; pool = "default"; config.size = "200GiB"; }
      { name = "cliproxy-data"; pool = "default"; config.size = "1GiB"; }
    ];
    profiles = [
      {
        name = "media";
        description = "qBittorrent, Prowlarr, Seedstrem and the public gateway";
        config = {
          "limits.cpu" = "4";
          "limits.memory" = "4GiB";
          "security.nesting" = "true";
        };
        devices = {
          data = { type = "disk"; pool = "default"; source = "media-data"; path = "/srv/media"; };
          qbittorrent = forward "0.0.0.0" 8080;
          seedstrem = forward "0.0.0.0" 8081;
          prowlarr = forward "0.0.0.0" 9696;
          public-gateway = forward "127.0.0.1" 8082;
        };
      }
      {
        name = "cliproxy";
        description = "CLIProxyAPI";
        config = {
          "limits.cpu" = "2";
          "limits.memory" = "1GiB";
          "security.nesting" = "true";
        };
        devices = {
          data = { type = "disk"; pool = "default"; source = "cliproxy-data"; path = "/srv/cliproxy"; };
          api = proxy "tcp:0.0.0.0:8318" "tcp:127.0.0.1:8317";
        } // lib.listToAttrs (map (port: lib.nameValuePair "oauth-${toString port}" (forward "127.0.0.1" port))
          [ 8085 1455 54545 51121 11451 ]);
      }
    ];
  };

  systemd.services = lib.mapAttrs' (name: guest:
    lib.nameValuePair "incus-guest-${name}" (deploy name guest)) guests;
}
