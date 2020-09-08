# nix-channel --add https://nixos.org/channels/nixos-20.03 nixos
# nix-channel --add https://nixos.org/channels/nixos-20.03-small nixos-small
# nix-channel --add https://nixos.org/channels/nixos-unstable unstable
# nix-channel --update
#
{ config, pkgs, ... }:

let
  unstable = import <unstable> {};
  nixos-small = import <nixos-small> {};
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

  boot.kernelPackages = nixos-small.linuxPackages_latest;
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

  system.stateVersion = "20.03";

  nix = {
    trustedUsers = [ "root" "user" ];
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
