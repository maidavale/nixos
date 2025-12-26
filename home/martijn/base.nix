{ config, pkgs, lib, ... }:

{
  home.username = "martijn";
  home.homeDirectory = "/home/martijn";

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}

