{ config, lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot = {
    initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
    # Udev discovers the Incus VG before the host's normal modules are loaded.
    initrd.kernelModules = [ "dm_thin_pool" "dm_snapshot" ];
    kernelModules = [ "kvm-intel" "dm_thin_pool" "dm_snapshot" ];
  };
  services.lvm.boot.thin.enable = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos-root";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXOS-BOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  fileSystems."/home" = {
    device = "/dev/default/home-data";
    fsType = "ext4";
  };
  # Incus owns the remaining raw NVMe partition as an LVM thin pool.
  swapDevices = [ ];
}
