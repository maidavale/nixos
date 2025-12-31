{ config, pkgs, lib, ... }:

{
  # Initial install compatibility anchor; don’t change unless migrating state intentionally.
  home.stateVersion = "25.05";

  home.packages = [
    (pkgs.writeShellScriptBin "google-chrome" ''
      exec ${pkgs.google-chrome}/bin/google-chrome-stable \
        --ozone-platform=x11 \
        --use-angle=opengl \
        --ignore-gpu-blocklist \
        "$@"
    '')
  ];
}

