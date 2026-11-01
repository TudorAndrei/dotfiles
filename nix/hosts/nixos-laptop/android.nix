{ pkgs, unstable, ... }:
let
  androidPkgs = unstable.extend (final: _: { jdk_headless = final.jdk17; });
  jdk = androidPkgs.jdk17;
  android = androidPkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "37.0" ];
    buildToolsVersions = [ "37.0.0" ];
    toolsVersion = null;
    includeNDK = true;
    ndkVersions = [ "27.1.12297006" ];
    cmakeVersions = [ "3.22.1" ];
    includeEmulator = true;
    includeSystemImages = true;
    systemImageTypes = [ "google_apis_playstore" ];
    abiVersions = [ "x86_64" ];
  };
  sdk = android.androidsdk;
  sdkRoot = pkgs.runCommand "android-sdk-root" { } ''
    sdk=${sdk}/libexec/android-sdk
    mkdir -p $out/cmdline-tools
    for entry in "$sdk"/*; do
      [ "''${entry##*/}" = cmdline-tools ] || ln -s "$entry" $out/
    done
    ln -s "$sdk"/cmdline-tools/* $out/cmdline-tools/
    ln -s "$(echo "$sdk"/cmdline-tools/*)" $out/cmdline-tools/latest
  '';
in
{
  users.groups.adbusers = { };
  users.users.tudor.extraGroups = [ "kvm" "adbusers" ];
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ENV{ID_USB_INTERFACES}=="*:ff420[13]:*", MODE="0660", GROUP="adbusers"
  '';

  environment.systemPackages = [ sdk jdk ];
  environment.sessionVariables = {
    ANDROID_HOME = sdkRoot;
    ANDROID_SDK_ROOT = sdkRoot;
    JAVA_HOME = "${jdk}/lib/openjdk";
  };
  home-manager.users.tudor.home.file.".gradle/gradle.properties".text = ''
    org.gradle.jvmargs=-Xmx3g -XX:MaxMetaspaceSize=768m
    org.gradle.workers.max=4
    org.gradle.daemon.idletimeout=900000
    kotlin.daemon.jvmargs=-Xmx1g
  '';
  systemd.user.extraConfig = ''
    DefaultEnvironment="ANDROID_HOME=${sdkRoot}" "ANDROID_SDK_ROOT=${sdkRoot}" "JAVA_HOME=${jdk}/lib/openjdk"
  '';
}
