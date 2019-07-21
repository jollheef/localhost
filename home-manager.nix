{ config, pkgs, ... }:

let
  unstable = import <unstable> {};
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "7d68c46feb845c572ef335f824062f90fdebf655";
  };
in {
  imports = [ "${home-manager}/nixos" ];

  home-manager.users.user = {
    programs = {
      git = {
        enable = true;
        userName  = "Mikhail Klementev";
        userEmail = "blame@dumpstack.io";
        signing = {
          signByDefault = true;
          key = "0x1525585D1B43C62A";
        };
      };

      zsh = {
        enable = true;

        oh-my-zsh = {
          enable = true;
          theme = "gentoo";
          plugins = [ "git" "cp" "tmux-my" ];
          custom = "$HOME/.oh-my-zsh-custom";
        };

        sessionVariables = {
          LC_ALL = "en_US.utf8";
          LIBVIRT_DEFAULT_URI = "qemu:///system";
          GOPATH = "\${HOME}";
          PATH = "\${PATH}:\${HOME}/bin";

          GPG_TTY = "$(tty)";
          SSH_AUTH_SOCK = "$(gpgconf --list-dirs agent-ssh-socket)";

          ZSH_TMUX_AUTOSTART = "true";
          ZSH_TMUX_AUTOCONNECT = "true";
        };

        shellAliases = {
          mutt = "neomutt";
          vim = "emacs -nw";
          emacs = "emacs -nw";
          clipimage = "xclip -selection clipboard -target image/png -out > out.png";
        };

        initExtra = ''
          gpgconf --launch gpg-agent
          which apt >/dev/null 2>&1 && plugins=("\$\{(@)plugins:#tmux-my\}")
        '';
      };

      gpg.enable = true;
    };

    services = {
      gpg-agent = {
        enable = true;
        extraConfig = ''
          pinentry-program ${pkgs.pinentry}/bin/pinentry-curses
        '';
      };
    };

    home.file = {
      ".emacs.d/init.el".source = ./etc/emacs.el;
      ".xmonad/xmonad.hs".source = ./etc/xmonad.hs;

      ".mutt/mailcap".source = ./etc/mutt/mailcap;
      ".mutt/muttrc".source = ./etc/mutt/muttrc;
      ".mutt/signature".source = ./etc/mutt/signature;

      ".oh-my-zsh-custom/plugins/tmux-my/tmux-my.extra.conf".source = ./etc/tmux-my/tmux-my.extra.conf;
      ".oh-my-zsh-custom/plugins/tmux-my/tmux-my.only.conf".source = ./etc/tmux-my/tmux-my.only.conf;
      ".oh-my-zsh-custom/plugins/tmux-my/tmux-my.plugin.zsh".source = ./etc/tmux-my/tmux-my.plugin.zsh;

      ".config/user-dirs.dirs".source = ./etc/user-dirs.dir;
      ".config/dunst/dunstrc".source = ./etc/dunstrc;
      ".config/kitty/kitty.conf".source = ./etc/kitty.conf;
    };

    home.keyboard = {
      layout = "us,ru";
      options = [ "ctrl:nocaps" "grp:rctrl_toggle" ];
    };

    xsession = {
      enable = true;
      windowManager.command = "exec xmonad";
      initExtra = ''
        touchpad=$(xinput | grep -o 'TouchPad.*id=[0-9]*' | cut -d '=' -f 2)
        trackpoint=$(xinput | grep -o 'TrackPoint.*id=[0-9]*' | cut -d '=' -f 2)

        xsetroot -solid '#000000'

        xinput --disable $touchpad
        xinput --set-prop $trackpoint 'Device Accel Constant Deceleration' 0.20

        xhost +local

        kitty &
      '';
    };

    gtk = {
      enable = true;
      theme.name = "Adwaita-dark";
      font.name = "Ubuntu 12";
      iconTheme = {
        name = "Adwaita";
        package = pkgs.gnome3.adwaita-icon-theme;
      };
      gtk2.extraConfig = ''
        gtk-cursor-theme-name = capitaine-cursors;
      '';
      gtk3.extraConfig = { gtk-cursor-theme-name = "capitaine-cursors"; };
    };
  };
}
