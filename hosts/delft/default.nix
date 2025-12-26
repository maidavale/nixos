{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/boot.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop-gnome.nix
    ../../modules/nixos/audio-pipewire.nix
    ../../modules/nixos/users-martijn.nix
    ../../modules/nixos/packages-delft.nix
    ../../modules/nixos/stylix.nix
  ];

  networking.hostName = "delft";

  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  system.stateVersion = "25.11";
}

