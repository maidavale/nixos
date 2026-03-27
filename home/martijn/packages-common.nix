{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [

    fishPlugins.done
    fishPlugins.autopair

    wget
    tree
    htop
    ripgrep
    fd

    wl-clipboard
    claude-code

    (pkgs.writeShellScriptBin "zoom-xcb" ''
      export QT_QPA_PLATFORM=xcb
      exec ${pkgs.zoom-us}/bin/zoom "$@"
    '')
  ];
}

