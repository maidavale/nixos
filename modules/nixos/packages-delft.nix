{ config, pkgs, ... }:

let
  myRStudio = pkgs.rstudioWrapper.override {
    packages = with pkgs.rPackages; [
      tidyverse
      janitor
    ];
  };

in
{
  environment.systemPackages = with pkgs; [
        
    # browsers
    brave
    librewolf
    
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
    wget
    ripgrep    
    tree
    
  ];

}

