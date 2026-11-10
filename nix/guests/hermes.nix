{ inputs, ... }:
let
  state = "/var/lib/hermes";
in
{
  imports = [ inputs.hermes-agent.nixosModules.default ];

  networking.hostName = "hermes";

  services.hermes-agent = {
    enable = true;
    stateDir = state;
    environmentFiles = [ "${state}/secrets.env" ];
    settings.moa.enabled = false;
    settings.model = {
      provider = "custom";
      base_url = "http://127.0.0.1:8318/v1";
      key_env = "CLIPROXY_API_KEY";
      api_mode = "codex_responses";
      default = "gpt-6.1-terra";
    };
    backend = {
      mode = "dashboard";
      host = "0.0.0.0";
      port = 9119;
    };
  };

  systemd.tmpfiles.rules = [ "L+ /opt/data - - - - ${state}/.hermes" ];

  systemd.services = {
    hermes-agent.unitConfig.RequiresMountsFor = [ state ];
    hermes-backend.unitConfig.RequiresMountsFor = [ state ];
  };
}
