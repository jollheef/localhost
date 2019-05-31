{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.layout = "us,ru";
  services.xserver.xkbOptions = "ctrl:nocaps,grp:rctrl_toggle";
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.windowManager.xmonad.enable = true;
  services.xserver.windowManager.xmonad.enableContribAndExtras = true;

  programs.dconf.enable = true;
  programs.light.enable = true;

  hardware.opengl.extraPackages = [ pkgs.vaapiVdpau ];

  sound.enable = true;
  hardware.pulseaudio.enable = true;

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.4";
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      ubuntu_font_family
    ];
  };

  environment.etc."X11/xorg.conf.d/60-trackball.conf".text = ''
    Section "InputClass"
      Identifier      "Marble Mouse"
      MatchProduct    "Logitech USB Trackball"
      MatchIsPointer  "on"
      MatchDevicePath "/dev/input/event*"
      Driver          "evdev"

      Option "ButtonMapping"       "3 8 1 4 5 6 7 2 2"
      Option "EmulateWheel"        "true"
      Option "EmulateWheelButton"  "9"
      Option "EmulateWheelInertia" "10"
      Option "ZAxisMapping"        "4 5"
      Option "Emulate3Buttons"     "true"
    EndSection
  '';

  environment.etc."X11/xorg.conf.d/61-trackpoint.conf".text = ''
    Section "InputClass"
      Identifier      "Trackpoint Wheel Emulation"
      Driver          "evdev"
      MatchProduct    "TPPS/2 Elan TrackPoint"
      MatchDevicePath "/dev/input/event*"

      Option "EmulateWheel"                       "true"
      Option "EmulateWheelButton"                 "2"
      Option "Emulate3Buttons"                    "false"
      Option "XAxisMapping"                       "6 7"
      Option "YAxisMapping"                       "4 5"
      Option "Device Accel Constant Deceleration" "0.5"
    EndSection
  '';

  services.xserver.displayManager.lightdm = {
    background = "black";
    greeters.mini = {
      enable = true;
      user = "user";
    };
  };

  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" # Privacy Badger
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "aapbdbdomjkkjkaonfhkkikfgjllcleb" # Google Translate
      "naepdomgkenhinolocfifgehidddafch" # Browserpass
    ];
  };

  networking.localCommands = ''
    mkdir -p /tmp/chromium && chown user:users /tmp/chromium
  '';
}
