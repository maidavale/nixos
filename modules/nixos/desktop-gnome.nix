{ config, pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.printing.enable = true;

  services.gnome.gnome-browser-connector.enable = true;
}

