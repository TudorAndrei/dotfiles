{ ... }:
{
  # intel_pstate powersave still scales and boosts with hardware-managed P states.
  # One policy manager controls EPP and device runtime PM on AC and battery.
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
      RUNTIME_PM_DRIVER_DENYLIST = "mei_me";
      # Wi-Fi is currently the sole administration link, including during outages.
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";
      USB_AUTOSUSPEND = 0;
      WOL_DISABLE = "N";
    };
  };
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;
  services.irqbalance.enable = true;
}
