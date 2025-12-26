{ config, pkgs, lib, ... }:

{
  imports = [
    ./base.nix
    ./packages-common.nix
    ./stylix.nix

    ./programs/fish.nix
    ./programs/kitty.nix
    ./programs/neovim.nix
    ./programs/zellij.nix
    ./programs/git.nix

    ./dotfiles/starship.nix
    ./dotfiles/zellij.nix
  ];

  programs.home-manager.enable = true;
}

