{ config, pkgs, lib, ... }:

{
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

