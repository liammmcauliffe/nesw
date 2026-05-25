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

## 4) Edit variables for your machine

Before applying the configuration, you must manually enter your username so you do not lose sudo privileges.

Open `flake.nix` and replace `"YOUR_USERNAME"` with your actual username:

```nix
home-manager.users."YOUR_USERNAME" = {
```

Open `hosts/main/configuration.nix` and replace `"YOUR_USERNAME"`:

```nix
users.users."YOUR_USERNAME" = {
```

You can also adjust your `time.timeZone` and `i18n.defaultLocale` in this file if needed.

## 5) Apply config

```bash
sudo nixos-rebuild switch --flake .#main
```

Then reboot, log into your TTY, and start Hyprland:

```bash
start-hyprland
```

That is the baseline. Home Manager imports modules from `hosts/main/home.nix`; edit plain-text app config in `modules/hyprland/hyprland.conf` and `modules/fish/config.fish`.

## 6) Commit your changes

Once you've made these edits and replaced `"YOUR_USERNAME"` with your actual username (e.g. `"liam"`), commit it and push. You now have an incredibly stable repository that won't randomly break your system if you re-clone it!
