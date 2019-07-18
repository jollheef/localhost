{ config, pkgs, ... }:

let
  unstable = import <unstable> {};
  home-manager = builtins.fetchGit {
    url = "https://github.com/rycee/home-manager.git";
    rev = "7d68c46feb845c572ef335f824062f90fdebf655";
  };
in {
  imports = [ "${home-manager}/nixos" ];

  home-manager.users.user.programs = {
    git = {
      enable = true;
      userName  = "Mikhail Klementev";
      userEmail = "blame@dumpstack.io";
      signing = {
        signByDefault = true;
        key = "0x1525585D1B43C62A";
      };
    };
  };

  home-manager.users.user.home.file.".emacs.d/init.el".source = ./etc/emacs.el;
}
