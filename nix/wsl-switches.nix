{ pkgs, ... }:
{
  systemd.user.services.wsl-switches = {
    Unit.Description = "On and off switches for Homepage";
    Service = {
      ExecStart = "${pkgs.python3}/bin/python3 ${./wsl-switches.py} 100.70.0.10 8187 /usr/lib/wsl/lib/nvidia-smi comfyui";
      Restart = "always";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
