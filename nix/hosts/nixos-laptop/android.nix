{ pkgs, unstable, ... }:
let
  androidPkgs = import unstable.path {
    inherit (pkgs.stdenv.hostPlatform) system;
    config = {
      allowUnfree = true;
      android_sdk.accept_license = true;
    };
  };
  android = androidPkgs.androidenv.composeAndroidPackages {
    platformVersions = [ "36" "37.0" ];
    buildToolsVersions = [ "36.0.0" "37.0.0" ];
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
  users.users.tudor.extraGroups = [ "kvm" ];

  # ffmpeg (with libx264) lets T3's Device panel stream the emulator.
  environment.systemPackages = [ sdk pkgs.jdk17 pkgs.ffmpeg ];
  environment.sessionVariables = {
    ANDROID_HOME = sdkRoot;
    ANDROID_SDK_ROOT = sdkRoot;
    JAVA_HOME = "${pkgs.jdk17}/lib/openjdk";
  };
  home-manager.users.tudor.home.file.".gradle/gradle.properties".text = ''
    org.gradle.jvmargs=-Xmx3g -XX:MaxMetaspaceSize=768m
    org.gradle.workers.max=4
    org.gradle.daemon.idletimeout=900000
    kotlin.daemon.jvmargs=-Xmx1g
  '';
  systemd.user.extraConfig = ''
    DefaultEnvironment="ANDROID_HOME=${sdkRoot}" "ANDROID_SDK_ROOT=${sdkRoot}" "JAVA_HOME=${pkgs.jdk17}/lib/openjdk"
  '';
}
