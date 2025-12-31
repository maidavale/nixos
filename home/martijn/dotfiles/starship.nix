{ config, pkgs, lib, ... }:

{
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  home.file.".config/starship.toml" = {
    text = ''
      format = """
      $directory$git_branch$git_status
      $character
      """

      [directory]
      style = "bold blue"
      truncation_length = 3

      [git_branch]
      format = "[$symbol$branch]($style)"
      style = "bold purple"
      symbol = " "

      [git_status]
      format = "[($all_status$ahead_behind )]($style)"
      style = "bold yellow"
      conflicted = "✖"
      deleted = "✘"
      modified = "✚"
      renamed = "»"
      staged = "●"
      stashed = "≡"
      untracked = "?"
    '';
  };
}

