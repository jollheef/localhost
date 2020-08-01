{ config, pkgs, ... }:

let
  unstable = import <unstable> {};
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "8bbefa77f7e95c80005350aeac6fe425ce47c288"; # Updated 28 May 2020
  };
in {
  imports = [ "${home-manager}/nixos" ];

  home-manager.useUserPackages = true;

  home-manager.users.root = {
    programs = {
      zsh = {
        enable = true;
        oh-my-zsh = {
          enable = true;
          theme = "gentoo";
          plugins = [ "git" ];
        };
      };
    };
    home.file.".emacs.d/init.el".source = ./etc/emacs.el;
  };

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

      tmux = {
        enable = true;
        baseIndex = 1;
        historyLimit = 100500;
        keyMode = "emacs";
        extraConfig = ''
          unbind C-Space
          set -g prefix C-Space
          bind C-Space send-prefix

          set -g status off
        '';
        plugins = [ pkgs.tmuxPlugins.yank ];
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
          PATH = "\${PATH}:\${HOME}/bin:\${HOME}/.local/bin";

          ZSH_TMUX_AUTOSTART = "true";
          ZSH_TMUX_AUTOCONNECT = "true";

          NIX_AUTO_RUN = "true";
        };

        shellAliases = {
          mutt = "neomutt";
          vim = "emacs -nw";
          emacs = "emacs -nw";
          clipimage = "xclip -selection clipboard -target image/png -out > out.png";
        };

        initExtra = ''
          which apt >/dev/null 2>&1 && plugins=("\$\{(@)plugins:#tmux-my\}")
        '';
      };

      gpg = {
        enable = true;
        settings = {
          throw-keyids = false;
        };
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
        touchpad=$(xinput | grep -o 'Synaptics.*id=[0-9]*' | cut -d '=' -f 2)
        trackpoint=$(xinput | grep -o 'TrackPoint.*id=[0-9]*' | cut -d '=' -f 2)

        xsetroot -solid '#000000'

        xinput --disable $touchpad
        xinput --set-prop $trackpoint 'Device Accel Constant Deceleration' 0.20

        ${pkgs.xorg.xhost}/bin/xhost local:

        ln -fs /tmp/chromium .config/
        ln -fs /tmp/chromium .cache/

        ln -fs ${unstable.gtk3}/share/gsettings-schemas/gtk+3-*/glib-2.0 .local/share/

        kitty --class=viewShiftW3 &
        emacs &
        chromium &
        wire-desktop &
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
