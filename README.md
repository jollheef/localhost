# localhost

## Installation

    parted...
    cryptsetup...
    mount...

    nix-env -iA nixos.gitMinimal
    git clone https://code.dumpstack.io/infra/localhost.git /mnt/etc/nixos/

    nix-channel --add https://nixos.org/channels/nixos-unstable unstable
    nix-channel --update

    nixos-generate-config --root /mnt

    nixos-install
    reboot
