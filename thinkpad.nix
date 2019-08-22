# https://github.com/NixOS/nixos-hardware/blob/master/common/pc/laptop/cpu-throttling-bug.nix
{ config, pkgs, ... }:
{
  systemd.services.cpu-throttling = {
    enable = true;
    description = "CPU Throttling Fix";
    path = [ pkgs.msr-tools ];
    script = "wrmsr -a 0x1a2 0x3000000";
    serviceConfig.Type = "oneshot";
    wantedBy = [
      "timers.target"
    ];
  };

  systemd.timers.cpu-throttling = {
    enable = true;
    description = "CPU Throttling Fix";
    timerConfig = {
      OnActiveSec = 60;
      OnUnitActiveSec = 60;
      Unit = "cpu-throttling.service";
    };
    wantedBy = [
      "timers.target"
    ];
  };
}
