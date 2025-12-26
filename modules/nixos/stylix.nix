{ config, pkgs, ... }:

{
  stylix = {
    enable = true;

    # modules/nixos/stylix.nix -> ../../../wallpapers/...
    image = "${toString config._module.args.flakeRoot}/wallpapers/wallpaper_linux.jpg";

    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";

    targets.gnome.enable = true;
    targets.fish.enable = true;
  };
}

