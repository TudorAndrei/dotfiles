{ pkgs, ... }:
let
  cliproxyUrl = "http://127.0.0.1:8318";
  cliproxyKey = pkgs.writeShellApplication {
    name = "cliproxy-key";
    runtimeInputs = [ pkgs.incus pkgs.yq-go ];
    text = ''
      incus exec cliproxy -- cat /srv/cliproxy/config.yaml < /dev/null |
        yq '.access["api-keys"][0]'
    '';
  };
  claudeSettings = (pkgs.formats.json { }).generate "claude-settings.json" {
    apiKeyHelper = "${cliproxyKey}/bin/cliproxy-key";
    env = {
      ANTHROPIC_BASE_URL = cliproxyUrl;
      CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY = "1";
    };
  };
  loginKeyring = pkgs.writeText "login.keyring" ''
    [keyring]
    display-name=Login
    ctime=0
    mtime=0
    lock-on-idle=false
    lock-after=false
  '';
  codexConfig = (pkgs.formats.toml { }).generate "codex-cliproxy-config.toml" {
    model = "gpt-6-sol";
    model_provider = "cliproxy";
    model_providers.cliproxy = {
      name = "Home CLIProxyAPI";
      base_url = "${cliproxyUrl}/v1";
      wire_api = "responses";
      supports_websockets = false;
      auth = {
        command = "${cliproxyKey}/bin/cliproxy-key";
        timeout_ms = 10000;
        refresh_interval_ms = 0;
      };
    };
  };
in
{
  programs.nix-ld.enable = true;
  services.envfs.enable = true;
  users.users.tudor.linger = true;
  environment.localBinInPath = true;

  environment.systemPackages = with pkgs; [
    nodejs_24 gh ripgrep fd jq curl unzip cliproxyKey libsecret
  ];

  services.gnome.gnome-keyring.enable = true;
  systemd.user.services.keyring-unlock = {
    description = "Start the passwordless login keyring";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash -c 'printf \"\" | ${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --unlock --components=secrets'";
    };
  };

  systemd.tmpfiles.rules = [
    "d /home/tudor/.local/share/keyrings 0700 tudor users -"
    "f /home/tudor/.local/share/keyrings/default 0600 tudor users - login"
    "C /home/tudor/.local/share/keyrings/login.keyring 0600 tudor users - ${loginKeyring}"
    "d /home/tudor/.claude 0700 tudor users -"
    "L+ /home/tudor/.claude/settings.json - - - - ${claudeSettings}"
    "d /home/tudor/.codex-cliproxy 0700 tudor users -"
    "C /home/tudor/.codex-cliproxy/config.toml 0600 tudor users - ${codexConfig}"
  ];
}
