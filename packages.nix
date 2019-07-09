{ config, pkgs, ... }:

let
  unstable = import <unstable> {};
in {
  nixpkgs.config.allowUnfree = true;

  programs.zsh.enable = true;
  programs.browserpass.enable = true;
  programs.adb.enable = true;

  programs.java = {
    enable = true;
    package = unstable.pkgs.jdk11;
  };

  services.ntp.enable = true;
  services.tlp.enable = true;
  services.vnstat.enable = true;

  virtualisation.docker.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemuVerbatimConfig = ''
      namespaces = []
      user = "user"
      group = "users"
    '';
  };

  services.tor.enable = true;
  services.tor.client.enable = true;

  environment.systemPackages = with pkgs; [
    # nix
    patchelfUnstable nix-index
    appimage-run

    # utils
    wget tmux zsh vim emacs htop acpi bc p7zip mpv
    git pass unzip zip w3m whois dnsutils feh
    parted iotop nmap tldr sshfs pinentry_ncurses
    oathToolkit neomutt pciutils easyrsa openvpn
    lsof tcpdump ddcutil pmount woeusb tigervnc
    file mkpasswd irssi heroku hdparm debootstrap
    proot fakeroot fakechroot lm_sensors powertop
    exfat traceroute graphicsmagick-imagemagick-compat
    pdftk vnstat dunst ghostscript graphicsmagick
    browsh texlive.combined.scheme-full rubber pandoc
    jq socat

    # gpg-related
    gnupg unstable.yubikey-manager unstable.yubikey-personalization

    # virtualization
    nixops
    kvm
    virtmanager
    virtviewer
    spice
    spice-gtk

    (python3.withPackages(ps: with ps; [
      ipython
      pillow opencv3 torchvision
      # elpy
      autopep8 jedi yapf black flake8 rope
    ]))

    # dev
    go gnumake gcc clang clang-analyzer global
    maven binutils-unwrapped openssl bison flex fop libxslt
    cmake manpages unstable.gradle cargo rustc guile hydra
    gitRepo rustfmt bazel ghc zlib gperf ccache opencv gotools

    # re
    radare2 radare2-cutter

    # x render
    vdpauinfo

    cm_unicode

    # base x
    rofi xlibs.xmodmap ubuntu_font_family i3lock unstable.kitty
    xfce.xfce4notifyd libnotify gtk_engines x2x lxappearance-gtk3
    pulsemixer arc-theme xorg.xhost xclip
    gnome3.dconf gnome3.dconf-editor gsettings-desktop-schemas gsettings-qt
    xorg.xcursorthemes capitaine-cursors gnome3.cheese

    # x apps
    unstable.chromium escrotum unstable.wire-desktop unstable.tdesktop ssvnc tightvnc
    quaternion veracrypt evince krita gimp gnome3.gnome-maps
    android-file-transfer darktable xournal gnome3.eog audacious audacity
    matrique unstable.libreoffice electrum adobe-reader unstable.wireshark lmms
    unstable.firefox unstable.stellarium

    (writeShellScriptBin "torbrowser" "${unstable.tor-browser-unwrapped}/bin/firefox")
  ];
}
