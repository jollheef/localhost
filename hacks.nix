{ config, pkgs, ... }:

{
  imports = [ ./suspend.nix ];

  services.batteryNotifier = {  # suspend.nix
    enable = true;
    notifyCapacity = 20;
    suspendCapacity = 10;
  };

  boot.kernel.sysctl."net.ipv4.ip_default_ttl" = 65;
}
