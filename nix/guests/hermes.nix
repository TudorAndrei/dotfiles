{ inputs, lib, pkgs, ... }:
let
  state = "/var/lib/hermes";
  cliproxyapiProvider = pkgs.fetchFromGitHub {
    owner = "duu261";
    repo = "hermes-cliproxyapi-provider";
    rev = "08fdae8c4607851ac25a2870c19139f961cc95b7";
    name = "cliproxyapi-provider";
    hash = "sha256-GhCYH0hbZ7aNFZhXOQ4qXfUkgdqPy0yPXPhZIc+sARI=";
  };
in
{
  imports = [ inputs.hermes-agent.nixosModules.default ];

  networking.hostName = "hermes";

  services.hermes-agent = {
    enable = true;
    stateDir = state;
    environmentFiles = [ "${state}/secrets.env" ];
    extraPackages = with pkgs; [ ffmpeg nodejs ripgrep ];
    extraPlugins = [ cliproxyapiProvider ];
    settings.cliproxyapi.instances.home = {
      base_url = "http://127.0.0.1:8318";
      key_env = "CLIPROXY_API_KEY";
      groups = {
        claude.models = [ "none" ];
        xai.models = [ "none" ];
      };
    };
    settings.moa.enabled = false;
    settings.model = {
      provider = "cpa-home-codex";
      base_url = null;
      key_env = null;
      api_mode = null;
      default = "gpt-6.1-terra";
    };
    backend = {
      mode = "dashboard";
      host = "0.0.0.0";
      port = 9119;
    };
  };

  system.activationScripts.hermes-profile-plugins = lib.stringAfter [ "hermes-agent-setup" ] ''
    for dir in ${state}/.hermes/profiles/*/plugins; do
      [ -d "$dir" ] || continue
      ln -sfn ${cliproxyapiProvider} "$dir/cliproxyapi-provider"
      chown -h hermes:hermes "$dir/cliproxyapi-provider"
    done
  '';

  systemd.tmpfiles.rules = [ "L+ /opt/data - - - - ${state}/.hermes" ];

  systemd.services = {
    hermes-agent.unitConfig.RequiresMountsFor = [ state ];
    hermes-backend.unitConfig.RequiresMountsFor = [ state ];
  };
}
