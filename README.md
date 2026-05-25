# nesw

Hyprland + NixOS

## What this gives you

- A flake-based NixOS config
- Hyprland enabled system-wide
- Wayland portals configured
- Basic packages for first boot (`ghostty`, `nvim`, `git`)

## Quick Setup (recommended)

After cloning the repo, run the interactive wizard:

```bash
./setup.sh
```

The script walks you through hostname, timezone, and locale, writes `settings.nix`, copies your hardware config, and optionally runs `nixos-rebuild switch` and reboots. Your Linux user is the one you created during the NixOS install — run the wizard (and `nixos-rebuild`) with `sudo` from that account so Home Manager targets the right user.

> **Note:** The script will automatically pull in `gum` via `nix-shell` if it's missing to render the UI.

```bash
# On a fresh NixOS install, get git first if needed:
nix-shell -p git

git clone https://github.com/liammmcauliffe/nesw.git ~/nesw
cd ~/nesw
./setup.sh
```

## Manual Setup

If you prefer to do it step-by-step:

### 1. Get git working on fresh NixOS

If `git` is missing, use a temporary shell first:

```bash
nix-shell -p git
```

### 2. Clone this repo

```bash
git clone https://github.com/liammmcauliffe/nesw.git ~/nesw
cd ~/nesw
```

### 3. Copy your hardware config

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hosts/main/hardware-configuration.nix
```

### 4. Edit machine-specific values

Update these in `settings.nix`:

- `hostname`
- `timezone`
- `locale`

### 5. Apply config

```bash
sudo nixos-rebuild switch --flake .#main
```

The flake target comes from `settings.nix` → `hostname`. With the default settings, that target is `.#main`.

## First Boot

Reboot, log into the TTY with the user you created during install, and start Hyprland:

```bash
start-hyprland
```

That is the baseline. Home Manager imports modules from `hosts/main/home.nix`; edit plain-text app config in `modules/hyprland/hyprland.conf` and `modules/fish/config.fish`.

## Known Quirks

### "Build Failed" on First Run

During the initial `nixos-rebuild switch`, the build might report a failure regarding Home Manager "user activation" or "clobbering" existing dotfiles. Don't panic.

This is a common quirk when Home Manager attempts to deploy dotfiles to a fresh user directory for the very first time on a Live USB environment. Simply reboot your machine, log into the TTY with your install user, and the system will work perfectly. The activation scripts resolve themselves cleanly on the first proper boot.

## Notes for other users

This repo currently exposes one host target from `settings.nix`:

```bash
.#main
```

If someone else wants to reuse this, they should fork it and create their own host under `hosts/`.
