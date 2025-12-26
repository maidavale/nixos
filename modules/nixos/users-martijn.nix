{ config, pkgs, ... }:

{
  users.users.martijn = {
    isNormalUser = true;
    description = "Martijn Rats";
    extraGroups = [ "networkmanager" "wheel" "render" "video" ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}

