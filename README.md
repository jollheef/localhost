# Fully reproducible localhost

[Download NixOS installation ISO](https://nixos.org/nixos/download.html)

Notes:
1. I assume that latest **stable** (e.g. 21.11) ISO will be used for installation.
2. Default network configuration is VPN-only, so if you don't have plans to use it you need to change iptables rules (remove `iptables -P OUTPUT DROP` from `networking.nix`) and remove `services.openvpn.servers.vpn` from `networking.nix`.
3. GUI settings is optimized for 3840x2160 on 15".

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

    nix-channel --add https://nixos.org/channels/nixos-21.11 nixos
    nix-channel --add https://nixos.org/channels/nixos-21.11-small nixos-small
    nix-channel --add https://nixos.org/channels/nixos-unstable unstable
    nix-channel --update

    nixos-generate-config --root /mnt

    nixos-install
    reboot

## After install

Initial password for `user` is `user`.

    sudo nix-channel --add https://nixos.org/channels/nixos-21.11 nixos
    sudo nix-channel --add https://nixos.org/channels/nixos-21.11-small nixos-small
    sudo nix-channel --add https://nixos.org/channels/nixos-unstable unstable
    sudo nix-channel --update
