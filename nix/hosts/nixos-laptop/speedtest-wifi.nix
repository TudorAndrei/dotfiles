{ pkgs, unstable, ... }:
let
  dir = "/var/lib/speedtest-wifi";
  run = pkgs.writeShellScript "speedtest-wifi-run" ''
    set -euo pipefail
    out=$(${unstable.ookla-speedtest}/bin/speedtest --accept-license --accept-gdpr --interface=wlo1 --format=json)
    printf '%s\n' "$out" | ${pkgs.jq}/bin/jq -c . >> ${dir}/history.jsonl
    printf '%s\n' "$out" > ${dir}/latest.json.tmp
    mv ${dir}/latest.json.tmp ${dir}/latest.json
  '';
  common = {
    User = "speedtest";
    Group = "speedtest";
    StateDirectory = "speedtest-wifi";
    StateDirectoryMode = "0755";
    WorkingDirectory = dir;
    Environment = "HOME=${dir}";
  };
in
{
  users.users.speedtest = {
    isSystemUser = true;
    group = "speedtest";
    home = dir;
  };
  users.groups.speedtest = { };

  systemd = {
    services = {
      speedtest-wifi = {
        description = "Run an internet speed test over wlo1";
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        serviceConfig = common // {
          Type = "oneshot";
          ExecStart = "${run}";
        };
      };
      speedtest-wifi-http = {
        description = "Serve Wi-Fi speed test results";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = common // {
          ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8091 --bind 0.0.0.0 --directory ${dir}";
          Restart = "always";
          RestartSec = 5;
        };
      };
    };
    timers.speedtest-wifi = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "01/3:30";
        RandomizedDelaySec = "10m";
        Persistent = true;
      };
    };
  };

  networking.firewall.interfaces.wlo1.allowedTCPPorts = [ 8091 ];
}
