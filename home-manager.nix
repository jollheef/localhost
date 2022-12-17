{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz";
  };
in {
  imports = [ "${home-manager}/nixos" ];

  home-manager.useUserPackages = true;

  home-manager.users.root = {
    home.stateVersion = "22.11";
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
    home.stateVersion = "22.11";
    services.dunst = {
      enable = true;
      settings = {
        global = {
          font = "Ubuntu Mono 12";
        };
        ignore = {
          summary = "browserpass: Install native host app";
          format = "";
        };
      };
    };

    programs = {
      git = {
        enable = true;
        userName  = "Mikhail Klementev";
        userEmail = "blame@dumpstack.io";
        signing = {
          signByDefault = true;
          key = "0x1525585D1B43C62A";
        };
        extraConfig = {
          init = {
            defaultBranch = "default";
          };
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

          # git does not support shell aliases as subcommands, but also
          # there is no way to change the current working directory from
          # the subprocess. Emulating the required behavior with the wrapper
          function git {
            if [[ "$1" = "get" ]]; then
              REPO=$(echo $2 | sed 's;http.*://;;')
              REPO=$(echo $REPO | sed 's;\.git$;;')
              ${pkgs.git}/bin/git clone https://$REPO $GOPATH/src/$REPO
              cd $GOPATH/src/$REPO
            else
              ${pkgs.git}/bin/git $@
            fi
          }
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

        ln -fs ${pkgs.gtk3}/share/gsettings-schemas/gtk+3-*/glib-2.0 .local/share/

        ln -fs .config/tmux/tmux.conf .tmux.conf

        kitty --class=viewShiftW3 &
        emacs &
        chromium &
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
