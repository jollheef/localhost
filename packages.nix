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
    parted iotop nmap tldr sshfs
    oathToolkit neomutt pciutils easyrsa openvpn
    lsof tcpdump ddcutil pmount woeusb tigervnc
    file mkpasswd irssi heroku hdparm debootstrap
    proot fakeroot fakechroot lm_sensors powertop
    exfat traceroute graphicsmagick-imagemagick-compat
    pdftk vnstat dunst ghostscript graphicsmagick
    browsh texlive.combined.scheme-full rubber pandoc
    jq socat ffmpeg-full exiftool apktool mdl wine zstd

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
      PyGithub
      # elpy
      autopep8 jedi yapf black flake8 rope
      # Forensics
      binwalk
    ]))

    ((unstable.emacsPackagesNgGen emacsWithImagemagick).emacsWithPackages(epkgs:
      # MELPA (Milkypostman’s Emacs Lisp Package Archive)
      (with epkgs.melpaPackages; [
        # Programming languages modes
        haskell-mode rust-mode scala-mode csharp-mode d-mode
        solidity-mode php-mode go-mode elpy ponylang-mode
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

    # re
    radare2 radare2-cutter

    # x render
    vdpauinfo

    cm_unicode

    # base x
    rofi xlibs.xmodmap ubuntu_font_family i3lock unstable.kitty
    libnotify gtk_engines x2x
    pulsemixer arc-theme xorg.xhost xclip
    gnome3.dconf gnome3.dconf-editor gsettings-desktop-schemas gsettings-qt
    xorg.xcursorthemes capitaine-cursors gnome3.cheese

    # x apps
    escrotum unstable.wire-desktop ssvnc tightvnc
    quaternion veracrypt evince krita gimp gnome3.gnome-maps
    android-file-transfer darktable xournal gnome3.eog audacious audacity
    libreoffice electrum unstable.wireshark lmms

    (writeShellScriptBin "torbrowser" "${unstable.tor-browser-unwrapped}/bin/firefox")

    (writeShellScriptBin "git-get" "${git}/bin/git clone https://$1 $GOPATH/src/$1")

    (writeShellScriptBin "chromium" ''
      ${unstable.chromium}/bin/chromium --force-dark-mode \
                                      --start-maximized \
                                      $@
    '')
  ];
}
