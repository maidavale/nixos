{ config, pkgs, ... }:

let
  # Define RStudio
  myRStudio = pkgs.rstudioWrapper.override {
    packages = with pkgs.rPackages; [
      tidyverse
      janitor
    ];
  };

  # Ungoogled Chromium in X11 mode
  myChromiumX11 = pkgs.writeShellScriptBin "chromium-x11" ''
    export QT_QPA_PLATFORM=xcb
    export XDG_SESSION_TYPE=x11
    exec ${pkgs.ungoogled-chromium}/bin/chromium --ozone-platform=x11 "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    
    starship

    # communication apps
    signal-desktop

    # browsers
    brave
    myChromiumX11

    # gtk theme
    gruvbox-gtk-theme

    # gnome tweaks and extensions
    gnome-tweaks
    gnome-shell-extensions
    gnomeExtensions.caffeine
    gnomeExtensions.tiling-shell
    gnomeExtensions.user-themes

    # protonmail
    protonmail-desktop

    # fonts
    jetbrains-mono

    # R programming language
    myRStudio
  ];

  services.protonmail-bridge.enable = true;
}

