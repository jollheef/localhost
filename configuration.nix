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
      ./auto-update.nix
    ];

  time.timeZone = "UTC";

  boot.kernelPackages = unstable.linuxPackages_latest;
  boot.blacklistedKernelModules = [ "nouveau" ];

  i18n.defaultLocale = "en_US.UTF-8";

  console.font = "latarcyrheb-sun32";
  console.keyMap = "us";
  console.earlySetup = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

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

  system.stateVersion = "19.09";

  nix.trustedUsers = [ "user" ];
  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
}
