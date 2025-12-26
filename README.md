# NixOS configuration

This repository contains my **NixOS + Home Manager configuration**, managed declaratively with **flakes** and kept in sync via GitHub.

The entire configuration lives in:

```
~/.nixos
```

This repository is the **single source of truth** for all machines.

---

## Hosts

- **london**
- **delft**

Each host has:
- a NixOS system configuration
- a Home Manager configuration for user `martijn`

---

## Day-to-day workflow (IMPORTANT)

This is the standard workflow to keep the local system and GitHub in sync.

### On the machine where you make changes

1) **Pull latest changes**
```bash
cd ~/.nixos
git pull
```

2) **Edit `.nix` files**
Make the required changes anywhere in the repo.

3) **Apply the configuration (validate changes)**

If the change affects NixOS:
```bash
sudo nixos-rebuild switch --flake .#london
```

If the change affects Home Manager:
```bash
home-manager switch --flake .#"martijn@london"
```

(When unsure, it is safe to run both.)

4) **Review changes**
```bash
git status
git diff
```

5) **Commit**
```bash
git add -A
git commit -m "Describe the change"
```

6) **Push to GitHub**
```bash
git push
```

After this, GitHub contains the latest configuration.

---

## Syncing other machines

On another machine (e.g. `delft`):

```bash
cd ~/.nixos
git pull
sudo nixos-rebuild switch --flake .#delft
home-manager switch --flake .#"martijn@delft"
```

That machine is now fully in sync.

---

## Recommended expert habit

Prefer this order:

```
edit → commit → rebuild → push
```

This ensures:
- every system state is recorded in Git
- easy rollback or bisecting if something breaks

---

## Updating flake inputs

Occasionally update dependencies:

```bash
cd ~/.nixos
nix flake update
sudo nixos-rebuild switch --flake .#london
home-manager switch --flake .#"martijn@london"
git add flake.lock
git commit -m "flake update"
git push
```

---

## Authentication

GitHub access uses **SSH authentication** with a **dedicated GitHub SSH key per machine**.

- Private keys are **never committed**
- Each machine has its own GitHub SSH key
- Keys are added via GitHub → Settings → SSH and GPG keys

---

## Notes

- `flake.lock` **is committed** (expected for flakes)
- Build artifacts such as `result` are ignored via `.gitignore`
- Secrets must never be stored in plaintext in this repository  
  (use `sops-nix` or `agenix` if secrets are required)

---

## Rebuild quick reference

### london
```bash
sudo nixos-rebuild switch --flake ~/.nixos#london
home-manager switch --flake ~/.nixos#"martijn@london"
```

### delft
```bash
sudo nixos-rebuild switch --flake ~/.nixos#delft
home-manager switch --flake ~/.nixos#"martijn@delft"
```


