{ config, pkgs, lib, ... }:

{
  home.file.".config/starship.toml" = {
    text = ''
      format = """ $directory $character"""

      [directory]
      style = "bold blue"
      truncation_length = 3
    '';
  };
}

