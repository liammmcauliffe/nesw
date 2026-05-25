# nesw

Hyprland + NixOS

## What this gives you

- A flake-based NixOS config
- Hyprland enabled system-wide
- Wayland portals configured
- Basic packages for first boot (`ghostty`, `nvim`, `git`)

## 1) Get git working on fresh NixOS

If `git` is missing, use a temporary shell first:

```bash
nix-shell -p git
```

## 2) Clone this repo

```bash
git clone https://github.com/liammmcauliffe/nesw.git ~/nesw
cd ~/nesw
```

## 3) Copy your hardware config

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hosts/main/hardware-configuration.nix
```

## 4) Edit machine-specific values

Update these in `settings.nix`:

- `username`
- `hostname`
- `timezone`
- `locale`

## 5) Apply config

```bash
sudo nixos-rebuild switch --flake .#main
```

The flake target comes from `settings.nix` → `hostname`. With the default settings, that target is `.#main`.

Then reboot, log into TTY, and start Hyprland:

```bash
start-hyprland
```

That is the baseline. Home Manager imports modules from `hosts/main/home.nix`; edit plain-text app config in `modules/hyprland/hyprland.conf` and `modules/fish/config.fish`.

## Notes for other users

This repo currently exposes one host target from `settings.nix`:

```bash
.#main
```

If someone else wants to reuse this, they should fork it and create their own host under `hosts/`.
