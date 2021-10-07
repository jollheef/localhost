{ config, pkgs, ... }:

let
  nonfree = import <nixos> { config.allowUnfree = true; };
  secrets = import ./secrets.nix;
in {
  systemd.services.display-manager.serviceConfig = {
    StartLimitBurst = 16;
    StartLimitIntervalSec = 4;
  };

  services.xserver = {
    enable = true;
    layout = "us,ru"; # see also home-manager.nix
    xkbOptions = "ctrl:nocaps,grp:rctrl_toggle"; # see also home-manager.nix
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    dpi = 282;   # 15.6 inch, 3840x2160
  };

  services.xserver.xautolock = {
    enable = true;

    time = 5;                   # minutes
    locker = "${pkgs.xsecurelock}/bin/xsecurelock";

    notify = 10;                # seconds
    notifier = "${pkgs.libnotify}/bin/notify-send \"Locking in 10 seconds\"";

    extraOptions = [ "-secure" ];
  };

  location = {
    latitude = secrets.latitude;
    longitude = secrets.longitude;
  };

  services.redshift = {
    enable = true;
  };

  programs.dconf.enable = true;
  programs.light.enable = true;

  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];

  sound.enable = true;

  # > bluetooth audio
  services.blueman.enable = true;

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };
  # < bluetooth audio

  environment.variables = {
    GDK_SCALE = "2";
    GDK_DPI_SCALE = "0.4";
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      ubuntu_font_family
      noto-fonts-emoji
      cantarell_fonts
      cm_unicode
      google-fonts
      go-font
      cm_unicode

      nonfree.corefonts
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

  services.udev.extraHwdb = ''
    keyboard:usb:*
    evdev:input:*
      KEYBOARD_KEY_700E7=rightctrl # Super_R -> Control_R
      KEYBOARD_KEY_7B=leftalt # Muhenkan -> Alt_R
      KEYBOARD_KEY_38=muhenkan # Alt_R -> Muhenkan
      KEYBOARD_KEY_70=rightalt # KATAKANAHIRAGANA -> Alt_R
  '';

  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" # uBlock Origin
      "gcbommkclmclpchllfjekcdonpmejbdp" # HTTPS Everywhere
      "dbepggeogbaibhgnhhndojpepiihcmeb" # Vimium
      "aapbdbdomjkkjkaonfhkkikfgjllcleb" # Google Translate
      "naepdomgkenhinolocfifgehidddafch" # Browserpass
      "fihnjjcciajhdojfnbdddfaoknhalnja" # I don't care about cookies
      "kbfnbcaeplbcioakkpcpgfkobkghlhen" # Grammarly
      "mnjggcdmjocbbbhaepdhchncahnbgone" # SponsorBlock
    ];
    extraOpts = {
      DefaultBrowserSettingEnabled = true;

      TranslateEnabled = false;
      SpellcheckEnabled = false;
      SpellCheckServiceEnabled = false;
      PrintingEnabled = false;
      SearchSuggestEnabled = false;
      PasswordManagerEnabled = false;
      SafeBrowsingEnabled  = false;
      AutofillAddressEnabled = false;
      AutofillCreditCardEnabled = false;
      MetricsReportingEnabled = false;
      BuiltInDnsClientEnabled = false;
      EnableMediaRouter = false;
      PromotionalTabsEnabled = false;

      SyncDisabled = true;

      SigninAllowed = false;
      AudioCaptureAllowed = false;
      VideoCaptureAllowed = false;
      SSLErrorOverrideAllowed = false;
      AutoplayAllowed = false;

      # 0 = Disable browser sign-in
      BrowserSignin = 0;

      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderSearchURL = "https://duckduckgo.com/"
        + "?kae=d&k1=-1&kc=1&kav=1&kd=-1&kh=1&q={searchTerms}";

      # Do not allow any site to show desktop notifications
      DefaultNotificationsSetting = 2;
      # Do not allow any site to track the users' physical location
      DefaultGeolocationSetting = 2;
      # Block the Flash plugin
      DefaultPluginsSetting = 2;
    };
  };

  networking.localCommands = ''
    mkdir -p /tmp/chromium && chown user:users /tmp/chromium
    mkdir -p /tmp/downloads && chown user:users /tmp/downloads
  '';
}
