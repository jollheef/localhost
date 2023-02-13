{ config, pkgs, ... }:

{
  security.allowUserNamespaces = true;
  security.allowSimultaneousMultithreading = true;
  security.lockKernelModules = false;

  programs.ssh.startAgent = false;
  programs.gnupg = {
    agent.enable = true;
    agent.enableSSHSupport = true;
    agent.enableExtraSocket = true;
    agent.enableBrowserSocket = true;
    dirmngr.enable = true;
  };

  # Bus 001 Device 002: ID 1050:0404 Yubico.com Yubikey 4 CCID
  services.udev = {
    extraRules = ''
      ACTION=="add|change", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0404", MODE="0666"
    '';
  };

  systemd = {
    services = {
      "force-lock-after-suspend" = {
        serviceConfig.User = "user";
        description = "Force xsecurelock after suspend";
        before = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
        script = ''
          DISPLAY=:0 ${pkgs.xsecurelock}/bin/xsecurelock
        '';
      };
    };
  };

  # Allow manage backlight without sudo
  security.sudo = {
    enable = true;
    extraConfig = ''
      %wheel ALL=(ALL:ALL) NOPASSWD: ${pkgs.light}/bin/light
      %wheel ALL=(captive) NOPASSWD: ${pkgs.firefox}/bin/firefox
    '';
  };

  environment.systemPackages = with pkgs; [
    (writeShellScriptBin "captive" "sudo -H -u captive ${pkgs.firefox}/bin/firefox")
  ];
}
