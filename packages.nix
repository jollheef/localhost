{ config, pkgs, ... }:

let
  nonfree = import <nixos> { config.allowUnfree = true; };
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
    nonfree.codeql

    # utils
    wget tmux zsh vim htop acpi bc p7zip mpv
    git pass unzip zip w3m whois dnsutils nomacs
    parted iotop nmap tldr sshfs qrencode
    oathToolkit neomutt pciutils easyrsa openvpn
    lsof tcpdump ddcutil pmount woeusb
    file mkpasswd irssi heroku hdparm debootstrap
    proot fakeroot fakechroot lm_sensors powertop
    exfat traceroute graphicsmagick-imagemagick-compat
    pdftk vnstat dunst ghostscript graphicsmagick
    browsh texlive.combined.scheme-full rubber pandoc
    jq socat ffmpeg-full exiftool apktool mdl wine zstd
    cointop tesseract dislocker ffmpeg-normalize

    # gpg-related
    gnupg yubikey-manager yubikey-personalization

    # virtualization
    nixops
    kvm
    virtmanager
    virtviewer
    spice
    spice-gtk

    (nonfree.python3.withPackages(ps: with ps; [
      ipython
      pillow opencv3 torchvision
      PyGithub telethon
      # Forensics
      binwalk
    ]))

    (emacsWithPackages(epkgs:
      # MELPA (Milkypostman’s Emacs Lisp Package Archive)
      (with epkgs.melpaPackages; [
        # Programming languages modes
        haskell-mode rust-mode scala-mode csharp-mode d-mode
        solidity-mode php-mode go-mode ponylang-mode zig-mode
        goimports
        # Development
        helm-gtags slime xcscope go-autocomplete
        # Configuration languages modes
        nix-mode markdown-mode dockerfile-mode yaml-mode ssh-config-mode
        toml-mode pcap-mode
        # Version control
        magit git-gutter
        # Generic
        smex w3m org-kanban org-brain
        # Appearance
        zenburn-theme solarized-theme wc-mode
        # IM
        telega
        # NixOS
        company-nixos-options helm-nixos-options
      ])
      ++
      # GNU Elpa
      (with epkgs.elpaPackages; [
        # Programming languages modes
        cobol-mode
      ])
    ))

    # re
    radare2 radare2-cutter

    # x render
    vdpauinfo

    # fonts
    gnome3.gnome-font-viewer

    # base x
    rofi xlibs.xmodmap xsecurelock kitty
    libnotify gtk_engines x2x evtest
    pulsemixer arc-theme xclip
    gnome3.dconf gnome3.dconf-editor gsettings-desktop-schemas gsettings-qt
    xorg.xcursorthemes capitaine-cursors gnome3.cheese

    # x apps
    escrotum wire-desktop evince gimp gnome3.gnome-maps
    android-file-transfer libreoffice electrum gnome3.nautilus
    signal-desktop rdesktop telegram-desktop

    (writeShellScriptBin "git-get" "${git}/bin/git clone https://$1 $GOPATH/src/$1")

    (writeShellScriptBin "chromium" ''
      ${chromium}/bin/chromium --force-dark-mode \
                                      --start-maximized \
                                      $@
    '')
  ];
}
