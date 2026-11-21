{ unstable, ... }:
{
  services.music-assistant = {
    enable = true;
    package = unstable.music-assistant;
    providers = [ "opensubsonic" "sendspin" "squeezelite" ];
  };

  networking.firewall.interfaces.wlo1 = {
    allowedTCPPorts = [ 3483 8095 8097 8384 ];
    allowedUDPPorts = [ 3483 ];
  };
}
