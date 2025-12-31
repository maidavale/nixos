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
    ../../modules/nixos/virtualisation-podman.nix
    ../../modules/nixos/services/ivpn.nix
  ];

  networking.hostName = "delft";

  services.xserver.xkb = {
    layout = "gb";
    variant = "";
  };
  console.keyMap = "uk";

  # Initial install compatibility anchor; don’t change unless migrating state intentionally
  system.stateVersion = "25.11";
}

