{ config, pkgs, ... }:

let
  unstable = import <unstable> {};
  emacsWithImagemagick = (unstable.emacs.override {
    srcRepo = true;
    imagemagick = unstable.imagemagickBig;
  });
in {
  programs.zsh.enable = true;
  programs.browserpass.enable = true;
  programs.adb.enable = true;
  programs.java.enable = true;

  services.ntp.enable = true;
  services.tlp.enable = true;
  services.vnstat.enable = true;
  services.kbfs.enable = true;

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
    wget tmux zsh vim htop acpi bc p7zip mpv
    git pass unzip zip w3m whois dnsutils feh
    parted iotop nmap tldr sshfs qrencode
    oathToolkit neomutt pciutils easyrsa openvpn
    lsof tcpdump ddcutil pmount woeusb tigervnc
    file mkpasswd irssi heroku hdparm debootstrap
    proot fakeroot fakechroot lm_sensors powertop
    exfat traceroute graphicsmagick-imagemagick-compat
    pdftk vnstat dunst ghostscript graphicsmagick
    browsh texlive.combined.scheme-full rubber pandoc
    jq socat ffmpeg-full exiftool apktool mdl wine zstd
    unstable.cointop

    # gpg-related
    gnupg unstable.yubikey-manager unstable.yubikey-personalization

    # keybase
    keybase keybase-gui

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
      PyGithub
      # Forensics
      binwalk
    ]))

    ((unstable.emacsPackagesNgGen emacsWithImagemagick).emacsWithPackages(epkgs:
      # MELPA (Milkypostman’s Emacs Lisp Package Archive)
      (with epkgs.melpaPackages; [
        # Programming languages modes
        haskell-mode rust-mode scala-mode csharp-mode d-mode
        solidity-mode php-mode go-mode ponylang-mode zig-mode
        # Development
        helm-gtags slime xcscope go-autocomplete
        # Configuration languages modes
        nix-mode markdown-mode dockerfile-mode yaml-mode ssh-config-mode
        toml-mode pcap-mode
        # Version control
        magit git-gutter
        # Generic
        smex w3m org-kanban
        # Appearance
        zenburn-theme solarized-theme
        # IM
        telega
      ])
      ++
      # GNU Elpa
      (with epkgs.elpaPackages; [
        # Programming languages modes
        cobol-mode
      ])
    ))

    # dev
    go gnumake gcc clang clang-analyzer global ponyc
    maven binutils-unwrapped openssl bison flex fop libxslt
    cmake manpages unstable.gradle cargo rustc guile hydra
    gitRepo rustfmt bazel ghc zlib gperf ccache opencv gotools
    unstable.zig unstable.meson

    # re
    radare2 radare2-cutter

    # x render
    vdpauinfo

    cm_unicode

    # fonts
    ubuntu_font_family noto-fonts-emoji

    # base x
    rofi xlibs.xmodmap i3lock unstable.kitty
    libnotify gtk_engines x2x evtest
    pulsemixer arc-theme xorg.xhost xclip
    gnome3.dconf gnome3.dconf-editor gsettings-desktop-schemas gsettings-qt
    xorg.xcursorthemes capitaine-cursors gnome3.cheese

    # x apps
    escrotum unstable.wire-desktop tightvnc
    quaternion veracrypt evince krita gimp gnome3.gnome-maps unstable.blender
    android-file-transfer darktable xournal gnome3.eog audacious audacity
    libreoffice electrum unstable.wireshark lmms gnome3.nautilus
    unstable.signal-desktop

    # TODO return to unstable
    (writeShellScriptBin "torbrowser" "${tor-browser-unwrapped}/bin/firefox")

    (writeShellScriptBin "git-get" "${git}/bin/git clone https://$1 $GOPATH/src/$1")

    (writeShellScriptBin "chromium" ''
      ${unstable.chromium}/bin/chromium --force-dark-mode \
                                      --start-maximized \
                                      $@
    '')
  ];
}
