# Fully reproducible localhost

[Download NixOS installation ISO](https://nixos.org/nixos/download.html)

## Installation

    parted /dev/vda mklabel gpt
    parted /dev/vda mkpart EFI fat32 0% 512M
    parted /dev/vda set 1 esp on
    parted /dev/vda mkpart NIX ext4 512M 100%

    cryptsetup luksFormat /dev/vda2
    cryptsetup open /dev/vda2 nix

    mkfs.vfat -F32 /dev/vda1
    mkfs.ext4 /dev/mapper/nix

    mount /dev/mapper/nix /mnt/
    mkdir /mnt/boot
    mount /dev/vda1 /mnt/boot

    nix-env -iA nixos.gitMinimal
    git clone https://code.dumpstack.io/infra/localhost.git /mnt/etc/nixos/

    cd /mnt/etc/nixos

    cp wireless-networks.nix.example wireless-networks.nix
    nano wireless-networks.nix

    cp secrets.nix.example secrets.nix
    nano secrets.nix

    nix-channel --add https://nixos.org/channels/nixos-unstable unstable
    nix-channel --update

    nixos-generate-config --root /mnt

    nixos-install
    reboot

## After install

Initial password for root is `root`, and for user is `user`.

Default network configuration is VPN-only, so if you don't have plans to use it you need to change iptables rules (remove `iptables -P OUTPUT DROP` from `networking.nix`) and remove `services.openvpn.servers.vpn` from `networking.nix`.
