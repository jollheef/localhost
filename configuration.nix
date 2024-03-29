# nix-channel --add https://nixos.org/channels/nixos-22.11 nixos
# nix-channel --add https://nixos.org/channels/nixos-unstable unstable
# nix-channel --update
#
{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./packages.nix
      ./networking.nix
      ./desktop.nix
      ./security.nix
      ./hacks.nix
      ./home-manager.nix
      ./thinkpad.nix
      ./auto-update.nix
      ./local.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [ "nouveau.modeset=0" ]; # comment out in case of nvidia

  time.timeZone = "UTC";

  services.logind.extraConfig = ''
    LidSwitchIgnoreInhibited=no
  '';

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  i18n.defaultLocale = "en_US.UTF-8";

  console.font = "latarcyrheb-sun32";
  console.keyMap = "us";
  console.earlySetup = true;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  services.fwupd.enable = true;

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
  boot.supportedFilesystems = [ "ntfs" ];

  system.stateVersion = "22.11";

  nix = {
    settings.trusted-users = [ "root" "user" ];
    optimise.automatic = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
