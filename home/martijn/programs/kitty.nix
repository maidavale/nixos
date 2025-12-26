{ config, pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    font.name = lib.mkForce "JetBrains Mono";
    font.size = lib.mkForce 11;
  };
}

