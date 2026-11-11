{ inputs, pkgs, lib, ... }:
let
  state = "/srv/cliproxy";
  cliproxyapi = inputs.cliproxyapi.packages.${pkgs.stdenv.hostPlatform.system}.cliproxyapi;
in
{
  networking.hostName = "cliproxy";
  environment.systemPackages = [ cliproxyapi ];

  systemd.services.cliproxyapi = {
    description = "CLIProxyAPI";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    unitConfig.RequiresMountsFor = [ state ];
    serviceConfig = {
      ExecStart = "${lib.getExe cliproxyapi} -config ${state}/config.yaml";
      WorkingDirectory = state;
      Restart = "always";
      NoNewPrivileges = true;
      PrivateTmp = true;
      ProtectSystem = "full";
    };
  };
}
