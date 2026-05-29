{ config, pkgs, pkgsUnstable, ... }:

let
  myRStudio = pkgs.rstudioWrapper.override {
    packages = with pkgs.rPackages; [
      tidyverse
      janitor
      httr
      jsonlite
      tsibble
      zoo
      xts
      ggfx
    ];
  };
in
{
  environment.systemPackages = with pkgs; [
    # terminals / editor / shell UX
    yazi    

    # basics
    fastfetch
    dig
    yt-dlp
    filezilla

    # office
    libreoffice

    # comms
    signal-desktop
    discord

    # browsers
    librewolf
    brave
    google-chrome

    # 1Password
    _1password-cli
    _1password-gui

    # theming/gnome
    gruvbox-gtk-theme
    gnome-tweaks
    gnome-shell-extensions
    gnomeExtensions.caffeine
    gnomeExtensions.tiling-shell
    gnomeExtensions.user-themes

    # protonmail
    protonmail-desktop

    # fonts
    jetbrains-mono

    # R
    myRStudio

    # transcription
    whisper-ctranslate2

    # zoom (you also wrap it in HM, but having it installed system-wide is fine)
    # Pulled from unstable for the newer 7.x release (stable 25.11 is still on 6.6).
    pkgsUnstable.zoom-us
  ];


}

