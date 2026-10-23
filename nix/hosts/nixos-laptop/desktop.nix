{ ... }:
{
  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.xserver.displayManager.lightdm.enable = false;

  services.xrdp = {
    enable = true;
    defaultWindowManager = "xfce4-session";
  };
}
