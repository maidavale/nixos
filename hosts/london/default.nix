{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/nixos/boot.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/desktop-gnome.nix
    ../../modules/nixos/audio-pipewire.nix
    ../../modules/nixos/users-martijn.nix

    ../../modules/nixos/virtualisation-podman.nix
    ../../modules/nixos/nextdns.nix
    ../../modules/nixos/packages-london.nix
    ../../modules/nixos/stylix.nix

    ../../modules/nixos/services/protonmail-bridge.nix
    ../../modules/nixos/services/ivpn.nix
  ];

  networking.hostName = "london";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Your custom NextDNS module (from nextdns.nix)
  services.myNextDNS.enable = true;
  services.myNextDNS.nextdnsId = "af344f";

  # Important with your NextDNS stub on 127.0.0.1:53
  networking.networkmanager.dns = "systemd-resolved";

  nix.settings.auto-optimise-store = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  # Initial install compatibility anchor; don’t change unless migrating state intentionally.
  system.stateVersion = "25.05";
}

