{ pkgs, ... }:
let
  jack = "alsa_output.platform-fe00b840.mailbox.stereo-fallback";
in
{
  imports = [ ./speedtest.nix ];

  home = {
    username = "user";
    homeDirectory = "/home/user";
    stateVersion = "26.05";
  };

  targets.genericLinux = {
    enable = true;
    gpu.enable = false;
  };
  programs.home-manager.enable = true;

  systemd.user.services.squeezelite = {
    Unit = {
      Description = "Squeezelite player for Music Assistant";
      After = [ "pipewire-pulse.service" ];
      Wants = [ "pipewire-pulse.service" ];
    };
    Service = {
      ExecStart = "${pkgs.squeezelite-pulse}/bin/squeezelite-pulse -n rpi -o ${jack}";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
