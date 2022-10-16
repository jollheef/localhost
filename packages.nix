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
  mygui-new = unstable.mygui.overrideAttrs (attrs: {
    version = "3.4.1";
    src = unstable.fetchFromGitHub {
      owner = "MyGUI";
      repo = "mygui";
      rev = "MyGUI3.4.1";
      sha256 = "sha256-5u9whibYKPj8tCuhdLOhL4nDisbFAB0NxxdjU/8izb8=";
    };
  });
  openmw-master = unstable.openmw.overrideAttrs (attrs: {
    version = "master";
    src = unstable.fetchFromGitHub {
      owner = "OpenMW";
      repo = "openmw";
      rev = "df8bd57a9e89d893559d771b840ea8eb757e079d";
      sha256 = "sha256-vhToZNlaC3ulH4/cdh2ajyFY3XxLnZIu4NTNZoBu7Tk=";
    };
    patches = [ ];
    buildInputs = [
      unstable.libyamlcpp
      unstable.luajit
      mygui-new
    ] ++ attrs.buildInputs;
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

  services.mysql = {
    enable = true;
    package = pkgs.mariadb;
    settings = {
      mysqld = {
        innodb_read_io_threads = 256;
        innodb_write_io_threads = 256;
        innodb_io_capacity = 100500;
        innodb_buffer_pool_size = "28G";
        innodb_log_buffer_size = "256M";
        innodb_log_file_size = "1G";
        innodb_flush_log_at_trx_commit = 0;
        innodb_doublewrite = 0;
        innodb_open_files = 100500;
      };
    };
  };

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
    binutils conda zopfli graphviz
    unstable.libimobiledevice unstable.ifuse

    unstable.exoscale-cli unstable.metal-cli

    # development
    sbcl go global

    openmw-master

    # gpg-related
    gnupg yubikey-manager yubikey-personalization

    # virtualization
    qemu_kvm
    virtmanager
    virt-viewer
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

    (unstable.emacs.pkgs.withPackages(epkgs:
      # MELPA (Milkypostman’s Emacs Lisp Package Archive)
      (with epkgs.melpaPackages; [
        # Programming languages modes
        haskell-mode rust-mode scala-mode csharp-mode d-mode
        solidity-mode go-mode ponylang-mode zig-mode
        gotools lua-mode
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
    rofi xorg.xmodmap xsecurelock kitty
    libnotify gtk_engines x2x evtest
    pulsemixer arc-theme xclip
    dconf gnome3.dconf-editor gsettings-desktop-schemas gsettings-qt
    xorg.xcursorthemes capitaine-cursors gnome3.cheese

    # x apps
    escrotum evince gimp gnome3.gnome-maps inkscape
    android-file-transfer libreoffice electrum gnome3.nautilus
    signal-desktop signal-cli rdesktop wire-desktop

    ghidra nonfree.davinci-resolve

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
