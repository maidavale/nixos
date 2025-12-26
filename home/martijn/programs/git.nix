{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "Martijn Rats";
        email = "mrats@pm.me";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };
}

