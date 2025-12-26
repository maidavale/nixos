{ config, pkgs, ... }:

let
  myRStudio = pkgs.rstudioWrapper.override {
    packages = with pkgs.rPackages; [
      tidyverse
      janitor
    ];
  };

  myChromiumX11 = pkgs.writeShellScriptBin "chromium-x11" ''
    export QT_QPA_PLATFORM=xcb
    export XDG_SESSION_TYPE=x11
    exec ${pkgs.ungoogled-chromium}/bin/chromium --ozone-platform=x11 "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
        
    # browsers
    brave
    myChromiumX11
    
    # desktop
    gruvbox-gtk-theme
    gnome-tweaks
    gnome-shell-extensions
    gnomeExtensions.caffeine
    gnomeExtensions.tiling-shell
    gnomeExtensions.user-themes
    jetbrains-mono
    
    # communication    
    protonmail-desktop
    signal-desktop
    
    # RStudio
    myRStudio
    
    # small system utilities
    git
    wget
    ripgrep    
    tree
    
  ];

  services.protonmail-bridge.enable = true;
}

