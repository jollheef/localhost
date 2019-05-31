# localhost

## Installation

    parted...
    cryptsetup...
    mount...

    nix-env -iA nixos.gitMinimal
    git clone https://code.dumpstack.io/infra/localhost.git /mnt/etc/nixos/

    nixos-generate-config --root /mnt

    nixos-install
    reboot
