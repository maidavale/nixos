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
  --image docker.io/library/debian:12
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

## 6. Prevent NixOS host library leakage (critical)

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

## 7. Export Workspace UI to GNOME

Citrix does not ship a usable `.desktop` file.

### 7.1 Create desktop entry (inside container)

```bash
mkdir -p ~/.local/share/applications

cat > ~/.local/share/applications/citrix-selfservice.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Citrix Workspace
Exec=/usr/local/bin/citrix-selfservice
Icon=receiver
Terminal=false
Categories=Network;RemoteAccess;
StartupNotify=true
EOF
```

### 7.2 Export it (inside container)

```bash
distrobox-export --app ~/.local/share/applications/citrix-selfservice.desktop
```

---

## 8. Enable double‑click `.ica` files (host)

### 8.1 Host wrapper

```bash
mkdir -p ~/.local/bin

cat > ~/.local/bin/citrix-ica <<'EOF'
#!/usr/bin/env bash
exec distrobox enter citrix -- /usr/local/bin/wfica-clean "$@"
EOF

chmod +x ~/.local/bin/citrix-ica
```

Ensure PATH (fish):

```bash
fish_add_path ~/.local/bin
```

Test:

```bash
citrix-ica
```

---

### 8.2 Register `.ica` MIME handler

```bash
mkdir -p ~/.local/share/applications

cat > ~/.local/share/applications/citrix-ica.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Citrix ICA
Exec=/home/<user>/.local/bin/citrix-ica %f
MimeType=application/x-ica;
NoDisplay=true
EOF
```

Then:

```bash
xdg-mime default citrix-ica.desktop application/x-ica
```

Verify:

```bash
xdg-mime query default application/x-ica
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

- Do **not** use `--init` with Debian images
- Do **not** install `.deb` from `/run/host/...`
- Do **not** rely on `/usr/local` on NixOS host
- Do **not** run Citrix without cleaning GTK/GVFS env
- `wfica --version` is unreliable

---

## 11. Rationale

- Citrix expects a traditional Linux filesystem
- NixOS breaks those assumptions
- Containers restore them cleanly
- Explicit wrappers avoid ABI contamination
- File associations are deterministic

This setup has proven stable and reproducible.
