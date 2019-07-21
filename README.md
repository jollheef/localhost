# Fully reproducible localhost

## Installation

    parted...
    cryptsetup...
    mount...

    nix-env -iA nixos.gitMinimal
    git clone https://code.dumpstack.io/infra/localhost.git /mnt/etc/nixos/

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
