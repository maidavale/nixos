{ config, pkgs, lib, ... }:

{
  stylix = {
    image = "${toString config._module.args.flakeRoot}/wallpapers/wallpaper_linux.jpg";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    targets.firefox.enable = true;
    targets.kitty.enable = true;
  };
}

