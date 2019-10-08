# nix-channel --add https://nixos.org/channels/nixos-19.03 nixos
# nix-channel --add https://nixos.org/channels/nixos-unstable unstable
# nix-channel --update
#
{ config, pkgs, ... }:

let
  unstable = import <unstable> {};
in {
  imports =
    [ <nixpkgs/nixos/modules/profiles/hardened.nix>
      ./hardware-configuration.nix
      ./packages.nix
      ./networking.nix
      ./desktop.nix
      ./security.nix
      ./hacks.nix
      ./docker.nix
      ./home-manager.nix
      ./thinkpad.nix
    ];

  time.timeZone = "UTC";

  boot.kernelPackages = unstable.linuxPackages_latest;
  boot.kernelModules = [
    "pl2303"
    "fuse"
    "veth" "usbnet" "mii" "cdc_ether"
    "ipt_REJECT" "xt_CHECKSUM" "iptable_mangle"
    "snd_usb_audio"
    "thunderbolt" "intel_wmi_thunderbolt"
  ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.earlyVconsoleSetup = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  i18n = {
    consoleFont = "latarcyrheb-sun32";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  swapDevices = [
    { device = "/var/swapfile";
      size = 32768; # MiB
    }
  ];

  users.users.root.shell = pkgs.zsh;
  users.users.user = {
    initialPassword = "user";
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "audio" "libvirtd" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;

  # force update all channels
  systemd.services.nixos-upgrade.serviceConfig.ExecStartPre =
    "/bin/sh -c '${pkgs.nix}/bin/nix-channel --update'";

  systemd.timers.nixos-upgrade.timerConfig.OnBootSec = "30m";
  systemd.timers.nixos-upgrade.timerConfig.Persistent = true;

  system.stateVersion = "19.03";
  system.autoUpgrade.enable = true;

  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
}
