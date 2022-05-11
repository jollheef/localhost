{ config, pkgs, ... }:

let
  unstable = import <unstable> {};
  nonfree = import <nixos> {
    config.allowUnfree = true;
    chromium.enableWideVine = true;
  };
  ghidra = pkgs.ghidra-bin.overrideAttrs (attrs: {
    installPhase = ''
        ${attrs.installPhase}
        sed -i 's/uiScale=1/uiScale=2/' $out/lib/ghidra/support/launch.properties
      '';
  });
in {
  programs.zsh.enable = true;
  programs.browserpass.enable = true;
  programs.adb.enable = true;
  programs.java.enable = true;

  services.ntp.enable = true;
  services.tlp.enable = true;
  services.vnstat.enable = true;

  services.usbmuxd.enable = true;
  services.usbmuxd.user = "user";

  virtualisation.docker.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    qemu.verbatimConfig = ''
      namespaces = []
      user = "user"
      group = "users"
    '';
  };

  services.tor.enable = true;
  services.tor.client.enable = true;

  environment.systemPackages = with pkgs; [
    gnumake

    # utils
    wget tmux zsh vim htop acpi bc p7zip mpv
    git pass unzip zip w3m whois dnsutils nomacs
    parted iotop nmap tldr sshfs qrencode
    oathToolkit neomutt pciutils openvpn
    lsof tcpdump pmount woeusb
    file mkpasswd heroku hdparm debootstrap
    proot fakeroot fakechroot lm_sensors powertop
    exfat traceroute graphicsmagick-imagemagick-compat
    pdftk vnstat dunst ghostscript graphicsmagick
    texlive.combined.scheme-full rubber pandoc
    jq socat ffmpeg-full exiftool apktool mdl wine zstd
    tesseract dislocker ffmpeg-normalize mkvtoolnix-cli
    binutils conda zopfli libimobiledevice ifuse graphviz

    unstable.exoscale-cli unstable.metal-cli

    # development
    sbcl go

    # gpg-related
    gnupg yubikey-manager yubikey-personalization

    # virtualization
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

    uefi-firmware-parser

    (unstable.emacsWithPackages(epkgs:
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
        magit git-gutter git-timemachine
        # Generic
        smex w3m org-kanban org-brain org-roam use-package
        selectrum selectrum-prescient
        # Appearance
        zenburn-theme solarized-theme wc-mode
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
    escrotum evince gimp gnome3.gnome-maps inkscape
    android-file-transfer libreoffice electrum gnome3.nautilus
    signal-desktop signal-cli rdesktop wire-desktop

    ghidra

    (writeShellScriptBin "chromium" ''
      ${chromium}/bin/chromium --force-dark-mode \
                               --start-maximized \
                               $@
    '')
    (writeShellScriptBin "chromium-nonfree" ''
      ${nonfree.chromium}/bin/chromium --force-dark-mode \
                                       --start-maximized \
                                       $@
    '')
  ];
}
