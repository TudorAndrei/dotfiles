_:
{
  services = {
    xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
      displayManager.lightdm.enable = false;
    };
    speechd.enable = false;
    xrdp = {
      enable = true;
      defaultWindowManager = "xfce4-session";
    };
  };
}
