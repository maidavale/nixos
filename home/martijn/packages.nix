{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
    starship

    fishPlugins.done
    fishPlugins.autopair

    # force Zoom to start in X11, not in Wayland
    (pkgs.writeShellScriptBin "zoom" ''
      export QT_QPA_PLATFORM=xcb
      exec ${pkgs.zoom-us}/bin/zoom "$@"
    '')
  ];
}

