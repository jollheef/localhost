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
    };

    home.file = {
      ".emacs.d/init.el".source = ./etc/emacs.el;
      ".xmonad/xmonad.hs".source = ./etc/xmonad.hs;

      ".oh-my-zsh-custom/plugins/tmux-my/tmux-my.extra.conf".source = ./etc/tmux-my/tmux-my.extra.conf;
      ".oh-my-zsh-custom/plugins/tmux-my/tmux-my.only.conf".source = ./etc/tmux-my/tmux-my.only.conf;
      ".oh-my-zsh-custom/plugins/tmux-my/tmux-my.plugin.zsh".source = ./etc/tmux-my/tmux-my.plugin.zsh;
    };

    home.keyboard = {
      layout = "us,ru";
      options = [ "ctrl:nocaps" "grp:rctrl_toggle" ];
    };

    xsession.enable = true;
    xsession.windowManager.command = "exec xmonad";
  };
}
