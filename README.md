# NixOS configuration

## Rebuild
- london:
  sudo nixos-rebuild switch --flake ~/.nixos#london
  home-manager switch --flake ~/.nixos#"martijn@london"

- delft:
  sudo nixos-rebuild switch --flake ~/.nixos#delft
  home-manager switch --flake ~/.nixos#"martijn@delft"

## Update flake inputs
nix flake update

