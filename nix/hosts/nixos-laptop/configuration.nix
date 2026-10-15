{ pkgs, ... }:
{
  imports = [ ./nvidia.nix ./power.nix ./media-public.nix ./immich.nix ./homepage.nix ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  hardware.enableRedistributableFirmware = true;

  networking.hostName = "nixos-laptop";
  networking.networkmanager.enable = true;
  # NetworkManager's default metrics prefer wired links over Wi-Fi.
  # The Wi-Fi credential lives in /etc/NetworkManager/system-connections,
  # outside this flake and the publicly readable Nix store.
  networking.networkmanager.unmanaged = [ "interface-name:incusbr*" "interface-name:veth*" ];
  networking.nftables.enable = true;
  networking.firewall.enable = true;
  networking.firewall.interfaces.incusbr0 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 67 ];
  };
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.firewall.checkReversePath = "loose";

  time.timeZone = "Europe/Bucharest";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.package = pkgs.lixPackageSets.stable.lix;
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "@wheel" ];
    auto-optimise-store = true;
    # Host builds share 16 GiB RAM and CPU capacity with the guests.
    max-jobs = 2;
    cores = 8;
    min-free = 2147483648;
    max-free = 8589934592;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.users.tudor = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "incus-admin" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDN3b2tmU8MBXGKl3FlFOoK4yXsY3MDjVlPqxntAfrNV tudor@parnaie"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICBeWyH8UVnqE8dq04cUany476fWr/nUECUgp/3U/fgG tudor@piticu.local"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  services.tailscale = {
    enable = true;
    openFirewall = true;
    # Keep host Internet DNS on NetworkManager's router resolver. Tailscale
    # still supplies private routing; client devices can use MagicDNS.
    extraSetFlags = [ "--accept-dns=false" ];
  };

  # Keep running when the lid closes or the machine is idle/on battery.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
    IdleAction = "ignore";
  };
  systemd.targets = {
    sleep.enable = false;
    suspend.enable = false;
    hibernate.enable = false;
    hybrid-sleep.enable = false;
    suspend-then-hibernate.enable = false;
  };
  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.journald.extraConfig = "SystemMaxUse=512M";

  # Shut down cleanly before a prolonged outage exhausts the battery.
  systemd.services.battery-shutdown = {
    description = "Clean shutdown at critically low battery during an outage";
    serviceConfig.Type = "oneshot";
    script = ''
      for battery in /sys/class/power_supply/BAT*; do
        [ -r "$battery/status" ] && [ -r "$battery/capacity" ] || continue
        if [ "$(cat "$battery/status")" = "Discharging" ] &&
           [ "$(cat "$battery/capacity")" -le 5 ]; then
          ${pkgs.systemd}/bin/systemctl poweroff
        fi
      done
    '';
  };
  systemd.timers.battery-shutdown = {
    wantedBy = [ "timers.target" ];
    timerConfig = { OnBootSec = "1min"; OnUnitActiveSec = "1min"; };
  };

  virtualisation.incus = {
    enable = true;
    preseed = {
      networks = [{
        name = "incusbr0";
        type = "bridge";
        config = {
          "ipv4.address" = "10.77.0.1/24";
          "ipv4.nat" = "true";
          "ipv6.address" = "none";
        };
      }];
      storage_pools = [{
        name = "default";
        driver = "lvm";
        # Incus normalized the NVMe partition source to this volume group
        # during initialization. Keep it stable for subsequent preseeds.
        config.source = "default";
      }];
      profiles = [{
        name = "default";
        config = {
          "limits.cpu" = "2";
          "limits.memory" = "2GiB";
          "boot.autostart" = "true";
        };
        devices = {
          eth0 = { type = "nic"; name = "eth0"; network = "incusbr0"; };
          root = { type = "disk"; path = "/"; pool = "default"; size = "30GiB"; };
        };
      }];
    };
  };
  systemd.services.incus.unitConfig.RequiresMountsFor = [ "/var/lib/incus" ];
  systemd.services.nix-daemon.serviceConfig = {
    CPUWeight = 20;
    IOWeight = 20;
  };
  services.lvm.dmeventd.enable = true;
  services.smartd.enable = true;

  environment.systemPackages = with pkgs; [
    neovim git htop lvm2 rsync pciutils lm_sensors nvme-cli powertop
  ];
  environment.variables.EDITOR = "nvim";
  system.stateVersion = "26.05";
}
