{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    podman
    distrobox
  ];

  virtualisation.podman.enable = true;
}

