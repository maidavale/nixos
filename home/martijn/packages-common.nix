{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [

    fishPlugins.done
    fishPlugins.autopair

    wl-clipboard

    (pkgs.writeShellScriptBin "zoom" ''
      export QT_QPA_PLATFORM=xcb
      exec ${pkgs.zoom-us}/bin/zoom "$@"
    '')
  ];
}

