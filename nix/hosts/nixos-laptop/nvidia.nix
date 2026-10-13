{ config, lib, ... }:
{
  # NVIDIA's userspace libraries remain proprietary with open kernel modules.
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11" "nvidia-settings" "nvidia-persistenced"
    ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;
    nvidiaSettings = false;
    nvidiaPersistenced = false;
    dynamicBoost.enable = false;
    # This flag configures system suspend, which this server never uses.
    powerManagement.enable = false;
    modesetting.enable = true;
    moduleParams = {
      # NVIDIA's supported Ampere notebook default enables runtime D3.
      nvidia.NVreg_DynamicPowerManagement = "0x03";
      # Expose DRM nodes for Incus without using the GPU as the console.
      nvidia-drm.fbdev = lib.mkForce 0;
    };
  };
  boot.kernelModules = [ "nvidia_drm" ];

  # Both the GPU and its HDMI-audio PCI function must permit runtime suspend.
  services.udev.extraRules = ''
    ACTION=="add|bind", SUBSYSTEM=="pci", KERNEL=="0000:01:00.[01]", TEST=="power/control", ATTR{power/control}="auto"
  '';

  # Opt in per container: -p default -p nvidia. Default guests leave it idle.
  virtualisation.incus.preseed.profiles = [{
    name = "nvidia";
    description = "RTX 3070 Ti: CUDA/NVML and hardware video acceleration";
    config = {
      "nvidia.runtime" = "true";
      "nvidia.driver.capabilities" = "compute,utility,video";
    };
    devices = {
      gpu = {
        type = "gpu";
        gputype = "physical";
        pci = "0000:01:00.0";
      };
      # Nixpkgs keeps upstream ELF binaries for non-NixOS containers here.
      # The host binary has a Nix store interpreter that a guest cannot resolve.
      nvidia-smi = {
        type = "disk";
        source = "${config.hardware.nvidia.package.bin}/origBin/nvidia-smi";
        path = "/usr/local/bin/nvidia-smi";
        readonly = "true";
      };
    };
  }];
}
