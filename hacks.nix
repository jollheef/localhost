{ config, pkgs, ... }:

{
  imports = [ ./suspend.nix ];

  services.batteryNotifier = {  # suspend.nix
    enable = true;
    notifyCapacity = 20;
    suspendCapacity = 10;
  };

  boot.kernel.sysctl."net.ipv4.ip_default_ttl" = 65;

  systemd = {
    services = {
      "sid-chroot-mounts" = {
        enable = true;
        description = "Setup mounts for debian sid chroot";
        wantedBy = [ "multi-user.target" ];
        script = ''
          ls /home/user/chroots/sid-root/home/user/.zshrc && exit
          ${pkgs.utillinux}/bin/mount --bind /home/user /home/user/chroots/sid-root/home/user
          ${pkgs.utillinux}/bin/mount --bind /dev /home/user/chroots/sid-root/dev
          ${pkgs.utillinux}/bin/mount --bind /proc /home/user/chroots/sid-root/proc
          ${pkgs.utillinux}/bin/mount --bind /sys /home/user/chroots/sid-root/sys
        '';
        serviceConfig.Type = "oneshot";
      };
    };
  };
}
