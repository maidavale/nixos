{ config, pkgs, pkgsUnstable, lib, ... }:

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
    pkgsUnstable.claude-code
    pkgsUnstable.codex
    gh

    vscodium

    (pkgs.writeShellScriptBin "zoom-xcb" ''
      export QT_QPA_PLATFORM=xcb
      exec ${pkgsUnstable.zoom-us}/bin/zoom "$@"
    '')
  ];
}

