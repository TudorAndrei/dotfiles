{ cuda, lib, ... }:
let
  comfyui = cuda.comfyui.override {
    extraPackages = ps: [ ps.comfyui-manager ];
  };
in
{
  systemd.user.services.comfyui = {
    Unit.Description = "ComfyUI";
    Service = {
      Environment = [ "LD_LIBRARY_PATH=/usr/lib/wsl/lib" ];
      ExecStart = "${lib.getExe comfyui} --listen 0.0.0.0 --port 8188 --enable-manager";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
  };
}
