{ unstable, lib, ... }:
let
  state = "/srv/cliproxy";
in
{
  networking.hostName = "cliproxy";
  environment.systemPackages = [ unstable.cliproxyapi ];

  systemd.services.cliproxyapi = {
    description = "CLIProxyAPI";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.RequiresMountsFor = [ state ];
    serviceConfig = {
      ExecStart = "${lib.getExe unstable.cliproxyapi} -config ${state}/config.yaml";
      WorkingDirectory = state;
      Restart = "always";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
