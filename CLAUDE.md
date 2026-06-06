# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is Martijn's declarative NixOS + Home Manager configuration, managed with flakes. The repo lives at `~/.nixos` and is the single source of truth for all machines.

## Hosts

Three hosts, each with a NixOS system config (`hosts/<host>/`) and a Home Manager config for user `martijn`:
- **london** — `system.stateVersion = "25.05"`, US keyboard, has NextDNS + protonmail-bridge + ivpn + podman
- **delft** — `system.stateVersion = "25.11"`, GB keyboard
- **amsterdam** — note its `homeConfigurations` entry reuses `home/martijn/hosts/delft.nix` (not an amsterdam-specific file)

## Apply / rebuild commands

`sudo nixos-rebuild` cannot be run by Claude via Bash — hand the command to the user to run in their terminal. `home-manager switch` does not need sudo and can be run directly.

```bash
# NixOS system (replace london with the target host)
sudo nixos-rebuild switch --flake .#london

# Home Manager (note the quotes around user@host)
home-manager switch --flake .#"martijn@london"

# Check a build without switching
sudo nixos-rebuild build --flake .#london

# Update inputs
nix flake update
```

Workflow order the README recommends: **edit → commit → rebuild → push** (so every system state is recorded in git for easy rollback). Commit `flake.lock`; `result` symlinks are gitignored.

## Architecture

`flake.nix` is the entry point. Key structural decisions:

- **Two nixpkgs channels.** Stable is `nixos-25.11`; `nixpkgs-unstable` is imported separately and passed into every module as the `pkgsUnstable` arg via `_module.args`. Use `pkgsUnstable.<pkg>` for packages that need to track unstable (e.g. `claude-code`, `zoom-us`); everything else uses the normal `pkgs`. Do not add an overlay to mix channels — the unstable set is deliberately a separate arg.
- **`flakeRoot` arg.** `self` is passed as `_module.args.flakeRoot` so modules can reference repo files by absolute store path — e.g. the Stylix wallpaper at `${flakeRoot}/wallpapers/...`.
- **Separate NixOS vs Home Manager outputs.** `nixosConfigurations.<host>` and `homeConfigurations."martijn@<host>"` are built independently (HM is *not* the `home-manager.nixosModules` module). Both must be switched to fully apply a change. Host-specific HM wrappers live in `home/martijn/hosts/<host>.nix` so they never leak between hosts.
- **Stylix** theming (gruvbox-dark-medium) is wired in at both layers: `stylix.nixosModules.stylix` + `modules/nixos/stylix.nix` for system, and `stylix.homeModules.stylix` + `home/martijn/stylix.nix` for HM.

### Layout

- `hosts/<host>/default.nix` — composes the host by importing modules from `modules/nixos/`; sets hostname, keyboard, `stateVersion`, and host-only options (e.g. london's `services.myNextDNS`).
- `hosts/<host>/hardware-configuration.nix` — generated hardware config, host-specific.
- `modules/nixos/` — reusable system modules (`base.nix`, `boot.nix`, `desktop-gnome.nix`, `audio-pipewire.nix`, `users-martijn.nix`, `virtualisation-podman.nix`, `nextdns.nix`, etc.) plus `services/` for systemd-service-style modules. Package sets are split per host: `packages-london.nix`, `packages-delft.nix`.
- `home/martijn/default.nix` — imports `base.nix`, `packages-common.nix`, `stylix.nix`, and the `programs/` and `dotfiles/` modules; the per-host file from `home/martijn/hosts/` is appended in `flake.nix`.

## Conventions

- `nextdns.nix` defines a **custom module** under the `services.myNextDNS` option namespace (enabled per-host in `hosts/london/default.nix`). Follow this `services.my<Name>` pattern when adding new custom options.
- GUI apps that misbehave under Wayland are wrapped with `pkgs.writeShellScriptBin` to force X11/xcb (see `zoom-xcb` in `packages-common.nix`, `google-chrome-x11` in `hosts/london.nix`). Reuse this wrapper pattern rather than changing the session.
- `allowUnfree`, `citrix_workspace.enableEULA`, and `permittedInsecurePackages` are set centrally in `flake.nix`'s `mkPkgs` — add insecure-package allowances there, not in individual modules.
