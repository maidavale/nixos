{ config, pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;
    shellInit = ''
      starship init fish | source
    '';
  };
}

