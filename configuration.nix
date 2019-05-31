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
    ];

  time.timeZone = "UTC";

  boot.kernelPackages = pkgs.linuxPackages;

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
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "audio" "libvirtd" ];
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.tmpOnTmpfs = true;

  system.stateVersion = "19.03";
  system.autoUpgrade.enable = true;

  nix.optimise.automatic = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";
}
