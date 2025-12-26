{ config, pkgs, lib, ... }:

{
  home.file.".config/zellij/config.kdl".text = ''
    theme "gruvbox-dark"
  '';
}

