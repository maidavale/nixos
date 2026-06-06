# Citrix Workspace via Distrobox / Podman on NixOS

This README documents a **known‑good, reproducible setup** for running **Citrix Workspace** on **NixOS** using **Distrobox + Podman**, tested on both:

- **london** (desktop)
- **delft** (laptop)

The goal is:
- Stable Citrix Workspace UI
- Working double‑click on `.ica` files
- No GLIBC / GTK / GVFS conflicts with NixOS
- Minimal hacks, explicit configuration

---

## 0. Assumptions

- Host OS: **NixOS**
- Desktop: GNOME (Wayland or X11)
- Container runtime: **Podman**
- Container manager: **Distrobox ≥ 1.8**
- Container image: **`ubuntu:22.04`** (the live `citrix` box currently runs this, not Debian)
- Citrix Workspace: Linux `.deb` installer

We **do not rely on `/usr/local`** on the host (not guaranteed on NixOS).

---

## 1. Host prerequisites

Ensure Podman and Distrobox are installed:

```nix
virtualisation.podman.enable = true;

environment.systemPackages = with pkgs; [
  distrobox
];
```

Apply:

```bash
sudo nixos-rebuild switch
```

---

## 2. Create the Citrix container

**Important:**
- Do **not** use `--init`
- Do **not** over‑customise container home paths

```bash
distrobox create \
  --name citrix \
  --image docker.io/library/ubuntu:22.04
```

Enter using bash:

```bash
distrobox enter citrix -- bash -l
```

---

## 3. Prepare the Debian container

Inside the container:

```bash
sudo apt update
sudo apt install -y \
  ca-certificates wget xdg-utils \
  locales xterm dialog lsb-release dbus-x11 \
  libgtk-3-0 libnss3 libxss1 libasound2 \
  libxcomposite1 libxdamage1 libxrandr2 libgbm1 \
  libxkbcommon0 usbutils
```

Generate locales **before installing Citrix**:

```bash
sudo sed -i 's/^# *\(en_GB.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=en_GB.UTF-8
```

---

## 4. Install Citrix Workspace

### 4.1 Copy the `.deb` into the container

Do **not** install from `/run/host/...`.

```bash
cp /run/host/home/<user>/Downloads/icaclient_*_amd64.deb ~/
```

### 4.2 Install

```bash
sudo apt install -y ./icaclient_*_amd64.deb
```

If needed:

```bash
sudo TERM=xterm DEBIAN_FRONTEND=noninteractive dpkg --configure -a
```

Verify:

```bash
dpkg -l | grep icaclient
# must show: ii  icaclient
```

---

## 5. Citrix binaries overview

- `/opt/Citrix/ICAClient/selfservice` → **Workspace UI**
- `/opt/Citrix/ICAClient/wfica` → **ICA launcher**

Running `wfica` without an `.ica` file often shows:
> “Corrupt ICA file”

This is **expected**.

---

## 6. Prevent NixOS host library leakage (optional troubleshooting)

> **Note:** The current working setup does **not** use these clean wrappers — the
> exported `.ica` handler calls `/opt/Citrix/ICAClient/adapter` directly (see §8) and
> works fine. Only add these wrappers if you actually hit host GVFS / GTK module
> errors (e.g. `Citrix` failing to load with `GIO`/`GTK` complaints).

Citrix must not load host GVFS / GTK modules.

### 6.1 Clean wrapper for `wfica`

```bash
sudo tee /usr/local/bin/wfica-clean >/dev/null <<'EOF'
#!/usr/bin/env bash
unset GIO_EXTRA_MODULES
unset GIO_MODULE_DIR
unset GTK_PATH
unset LD_LIBRARY_PATH
exec /opt/Citrix/ICAClient/wfica "$@"
EOF

sudo chmod +x /usr/local/bin/wfica-clean
```

### 6.2 Clean wrapper for Workspace UI

```bash
sudo tee /usr/local/bin/citrix-selfservice >/dev/null <<'EOF'
#!/usr/bin/env bash
unset GIO_EXTRA_MODULES
unset GIO_MODULE_DIR
unset GTK_PATH
unset LD_LIBRARY_PATH
exec /opt/Citrix/ICAClient/selfservice "$@"
EOF

sudo chmod +x /usr/local/bin/citrix-selfservice
```

Test:

```bash
citrix-selfservice &
```

---

## 7. Workspace UI launcher (optional)

> **Current state:** the Workspace UI (`selfservice`) is **not** exported to the GNOME
> menu. The only Citrix-related host entries are:
> - `~/.local/share/applications/citrix.desktop` — distrobox's auto-generated
>   "enter the container in a terminal" shortcut (created by `distrobox create`).
> - `~/.local/share/applications/citrix-wfica.desktop` — the exported `.ica` handler (see §8).
>
> In practice Citrix sessions are launched by double-clicking `.ica` files, so a
> standalone Workspace UI launcher isn't required. If you *do* want the UI in GNOME,
> Citrix ships its own `selfservice.desktop` inside the container — just export it:

```bash
# inside the container, Citrix already provides /usr/share/applications/selfservice.desktop
distrobox-export --app selfservice
```

This produces `~/.local/share/applications/citrix-selfservice.desktop` on the host,
wrapped to run via `distrobox enter`.

---

## 8. Enable double‑click `.ica` files (host)

This is done by exporting Citrix's own `wfica` desktop entry from the container,
**not** by hand-writing a host wrapper script.

### 8.1 Export the wfica handler (inside container)

Citrix's `.deb` installs `/usr/share/applications/wfica.desktop`, which already
declares `MimeType=application/x-ica;` and runs the ICA adapter:

```
Exec=/opt/Citrix/ICAClient/adapter -icaroot /opt/Citrix/ICAClient %f
```

Export it to the host:

```bash
distrobox-export --app wfica
```

This creates `~/.local/share/applications/citrix-wfica.desktop` on the host, with
the `Exec` line automatically wrapped in `distrobox-enter -n citrix -- …` so the
adapter runs inside the container.

### 8.2 Register it as the default `.ica` MIME handler (host)

```bash
xdg-mime default citrix-wfica.desktop application/x-ica
```

Verify:

```bash
xdg-mime query default application/x-ica
# expected: citrix-wfica.desktop
```

---

## 9. Final verification

- Citrix Workspace appears in GNOME
- Workspace UI launches
- Downloaded `.ica` files open by double‑click
- Citrix session connects
- No GLIBC / GVFS errors

---

## 10. Known pitfalls

- Do **not** use `--init` with Debian/Ubuntu images
- Do **not** install `.deb` from `/run/host/...`
- Do **not** rely on `/usr/local` on NixOS host
- `wfica --version` is unreliable

---

## 11. Rationale

- Citrix expects a traditional Linux filesystem
- NixOS breaks those assumptions
- Containers restore them cleanly
- Explicit wrappers avoid ABI contamination
- File associations are deterministic

This setup has proven stable and reproducible.
