{
  services.music-assistant = {
    enable = true;
    providers = [ "opensubsonic" "squeezelite" ];
  };

  networking.firewall.interfaces.wlo1 = {
    allowedTCPPorts = [ 3483 8095 8097 ];
    allowedUDPPorts = [ 3483 ];
  };
}
