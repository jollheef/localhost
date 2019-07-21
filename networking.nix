{ config, pkgs, ... }:

let
  secrets = import ./secrets.nix;
in {
  networking.hostName = "local";
  networking.nameservers = [ "1.1.1.1" ];

  networking.usePredictableInterfaceNames = false;

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

      # Allow access for special user for use captive portals without
      # disabling vpn-only restrictions (to avoid leaks at the first seconds
      # after connection)
      iptables -A OUTPUT -m owner --uid-owner captive \
               -p tcp -m multiport --dports 80,443,2443 \
               -j ACCEPT

      iptables -A OUTPUT -m owner --uid-owner captive \
               -p udp -m multiport --dports 53 \
               -j ACCEPT

      # iptables -A OUTPUT -d 192.0.2.17 -j ACCEPT
      ${secrets.iptables}
    '';
    checkReversePath = false;
  };

  # User without vpn-only restrictions (for captive portals)
  users.users.captive = {
    isNormalUser = true;
  };

  services.nscd.enable = false;

  services.openvpn.servers.vpn = {
    autoStart = true;
    config = secrets.vpn-config;
    authUserPass.username = secrets.vpn-username;
    authUserPass.password = secrets.vpn-password;
    updateResolvConf = true;
  };

  systemd = {
    services = {
      "macchanger-wlan0" = {
        description = "Changes MAC of wlan0 for privacy reasons";
        wants = [ "network-pre.target" ];
        wantedBy = [ "multi-user.target" ];
        before = [ "network-pre.target" ];
        bindsTo = [ "sys-subsystem-net-devices-wlan0.device" ];
        after = [ "sys-subsystem-net-devices-wlan0.device" ];
        script = "${pkgs.macchanger}/bin/macchanger -e wlan0 || true";
        serviceConfig.Type = "oneshot";
      };
      "macchanger-eth0" = {
        description = "Changes MAC of eth0 for privacy reasons";
        wants = [ "network-pre.target" ];
        wantedBy = [ "multi-user.target" ];
        before = [ "network-pre.target" ];
        bindsTo = [ "sys-subsystem-net-devices-eth0.device" ];
        after = [ "sys-subsystem-net-devices-eth0.device" ];
        script = "${pkgs.macchanger}/bin/macchanger -e eth0 || true";
        serviceConfig.Type = "oneshot";
      };
      "openvpn-restart-after-suspend" = {
        description = "Restart OpenVPN after suspend";
        after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        script = "${pkgs.systemd}/bin/systemctl try-restart openvpn-vpn.service";
      };
    };
  };
}
