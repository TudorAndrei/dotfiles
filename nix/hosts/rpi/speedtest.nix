{ pkgs, config, ... }:
let
  dir = "${config.home.homeDirectory}/speedtest";
  run = pkgs.writeShellScript "speedtest-run" ''
    set -euo pipefail
    mkdir -p ${dir}
    out=$(${pkgs.ookla-speedtest}/bin/speedtest --accept-license --accept-gdpr --interface=eth0 --format=json)
    printf '%s\n' "$out" | ${pkgs.jq}/bin/jq -c . >> ${dir}/history.jsonl
    printf '%s\n' "$out" > ${dir}/latest.json.tmp
    mv ${dir}/latest.json.tmp ${dir}/latest.json
  '';
  sync = pkgs.writeShellScript "speedtest-wifi-sync" ''
    set -euo pipefail
    ${pkgs.curl}/bin/curl -fsS --max-time 30 http://192.168.0.244:8091/history.jsonl -o ${dir}/wifi.jsonl.tmp
    mv ${dir}/wifi.jsonl.tmp ${dir}/wifi.jsonl
  '';
in
{
  home.file."speedtest/index.html".source = ./speedtest.html;

  systemd.user = {
    services = {
      speedtest = {
        Unit.Description = "Run an internet speed test over eth0";
        Service = {
          Type = "oneshot";
          ExecStart = "${run}";
        };
      };
      speedtest-wifi-sync = {
        Unit.Description = "Copy Wi-Fi speed test results from nixos-laptop";
        Service = {
          Type = "oneshot";
          ExecStart = "${sync}";
        };
      };
      speedtest-http = {
        Unit.Description = "Serve speed test results";
        Service = {
          ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${dir}";
          ExecStart = "${pkgs.python3}/bin/python3 -m http.server 8090 --bind 0.0.0.0 --directory ${dir}";
          Restart = "always";
          RestartSec = 5;
        };
        Install.WantedBy = [ "default.target" ];
      };
    };
    timers.speedtest-wifi-sync = {
      Unit.Description = "Copy Wi-Fi speed test results every 15 minutes";
      Timer = {
        OnCalendar = "*:0/15";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
    timers.speedtest = {
      Unit.Description = "Run an internet speed test every 3 hours";
      Timer = {
        OnCalendar = "00/3:00";
        RandomizedDelaySec = "10m";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
