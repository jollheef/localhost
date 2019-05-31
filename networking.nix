{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  networking.hostName = "local";
  networking.nameservers = [ "1.1.1.1" ];

  networking.wireless.enable = true;
  imports = [ ./wireless-networks.nix ];

  networking.firewall = {
    enable = true;
    extraCommands = ''
      iptables -F OUTPUT
      iptables -P OUTPUT DROP

      iptables -A OUTPUT -o lo+ -j ACCEPT
      iptables -A OUTPUT -o vpn+ -j ACCEPT
      iptables -A OUTPUT -o tun+ -j ACCEPT
      iptables -A OUTPUT -o tap+ -j ACCEPT
      iptables -A OUTPUT -o veth+ -j ACCEPT
      iptables -A OUTPUT -o vnet+ -j ACCEPT
      iptables -A OUTPUT -o docker+ -j ACCEPT
      iptables -A OUTPUT -o virbr+ -j ACCEPT
      iptables -A OUTPUT -o virbr0-nic -j ACCEPT

      # iptables -A OUTPUT -d 192.0.2.17 -j ACCEPT
      ${secrets.iptables}
    '';
    checkReversePath = false;
  };

  services.openvpn.servers.vpn = {
    autoStart = true;
    config = secrets.vpn-config;
    authUserPass.username = secrets.vpn-username;
    authUserPass.password = secrets.vpn-password;
    updateResolvConf = true;
  };

  systemd = {
    services = {
      "macchanger" = {
        description = "Changes MAC of all interfaces for privacy reasons";
        wants = [ "network-pre.target" ];
        wantedBy = [ "multi-user.target" ];
        before = [ "network-pre.target" ];
        bindsTo = [ "sys-subsystem-net-devices-wlp0s20f3.device" ];
        after = [ "sys-subsystem-net-devices-wlp0s20f3.device" ];
        # we always return true to avoid errors while 'nixos-rebuild switch'
        # because it does not stop interfaces
        # TODO it must be changed to work only when system starts
        script = ''
          ${pkgs.macchanger}/bin/macchanger -e wlp0s20f3 || true
          ${pkgs.macchanger}/bin/macchanger -e enp0s31f6 || true
        '';
        serviceConfig.Type = "oneshot";
      };
      "openvpn-restart-after-suspend" = {
        description = "Restart OpenVPN after suspend";
        after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        script = ''
          ${pkgs.systemd}/bin/systemctl try-restart openvpn-vpn.service
        '';
      };
    };
  };
}
