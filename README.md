# nesw

![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-58E1FF?logo=wayland&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

A modular NixOS + Hyprland desktop environment with a Quickshell UI layer, centralized theming, and a Lua config bridge. Designed to be forked, customized via options, and extended without patching core modules.

## ✨ Showcase

![Desktop Preview](./assets/desktop.png)

> Add your own screenshot or GIF at `assets/desktop.png` to show off your setup.

## Features

- **Flake-based multi-host layout** — `hosts/laptop/` with a self-contained `default.nix` entry point, ready to add more machines
- **Dynamic Lua–Hyprland bridge** — `variables.lua` and color scheme files generated from Nix options at build time
- **Centralized NixOS theming options** — `nesw.theme.fonts.*` and `nesw.theme.colors.*` drive fonts, Ghostty, Quickshell, and Hyprland borders
- **Quickshell Notch & Border UI** — top bar, rounded screen frame, workspace notch, clock, and app launcher
- **Home Manager module export** — `homeManagerModules.nesw` for importing into other flakes
- **Fish rebuild helpers** — `nswitch`, `ntest`, `nupdate`, and `nrollback` stage changes and rebuild from `~/nesw`
- **Live color reload** — optional `~/.local/state/nesw/scheme.json` for matugen/wallust without a rebuild

## Quick Start

### Prerequisites

- NixOS with flakes enabled (or willingness to enable them during install)
- A user account that will own the Home Manager profile
- Git

### 1. Clone the repository

On a fresh system without git:

```bash
nix-shell -p git
```

Clone to `~/nesw` (recommended — Fish rebuild helpers default to this path):

```bash
git clone https://github.com/liammmcauliffe/nesw.git ~/nesw
cd ~/nesw
```

### 2. Copy your hardware configuration

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hosts/laptop/hardware-configuration.nix
```

This file is gitignored so disk UUIDs and hardware-specific settings stay on your machine.

### 3. Set your username

In `flake.nix`, change `userName` in the `let` block to your Linux username:

```nix
userName = "YOUR_USERNAME";
```

This value is passed to Home Manager and `hosts/laptop/configuration.nix`. **It must match your account before the first rebuild** — a mismatch can leave you without sudo access.

### 4. Optional: create `local.nix` for overrides

Copy the example file and edit it with your preferences. This is the preferred way to customize without touching core modules:

```bash
cp hosts/laptop/local.nix.example hosts/laptop/local.nix
```

`local.nix` is imported by both `configuration.nix` and `home.nix` when it exists. Use it for `nesw.*` framework options (theme, default apps). See [Customization](#customization) below.

Adjust `time.timeZone` and `i18n.defaultLocale` in `hosts/laptop/configuration.nix` if needed.

### 5. Build and switch

```bash
sudo nixos-rebuild switch --flake .#main
```

Reboot, log into a TTY, and start Hyprland:

```bash
Hyprland
```

### 6. Day-to-day rebuilds

From any directory (Fish):

```bash
nswitch    # stage all changes, rebuild and switch
ntest      # test build (reverted on reboot)
nupdate    # update flake inputs, test build
nrollback  # switch to previous system generation
```

## Disaster recovery

If a rebuild breaks your system, Hyprland won't start, or you get stuck, don't panic.

### Case 1: System boots, but Hyprland is broken

1. Reboot.
2. At the `systemd-boot` menu, select an older NixOS generation.
3. Boot into it — you're in a working state.
4. Fix the issue in your config, or run `nrollback` to make that generation the default.

### Case 2: UI freezes while logged in

1. Switch to a TTY: `Ctrl+Alt+F2` (or F3, F4…).
2. Log in with your username and password.
3. Run `sync`, then `kill-ui` to stop Quickshell and Hyprland.
4. Run `Hyprland`, or `systemctl --user start graphical-session.target`.

### Case 3: `nswitch` fails with staged broken changes

Because `nswitch` runs `git add -A` first, broken changes may be staged but not committed.

1. From a TTY: `cd ~/nesw && git reset HEAD .`
2. Run `nrollback` to return to the last working system generation.
3. Fix your files and try again.

### Generations and Home Manager

`nrollback` rolls back the **system** configuration only. If a Home Manager change broke your user session, fix the Nix code and rebuild — or boot an older system generation that still has a working HM profile.

Check system generations:

```bash
nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Customization

nesw is built as a **framework**: defaults live in modules, and your machine-specific choices go in `hosts/laptop/local.nix`. Options use `lib.mkDefault`, so anything you set in `local.nix` wins without editing upstream files.

### Where to edit what

| You want to… | Do this |
|--------------|---------|
| Change the default terminal | `nesw.desktop.hyprland.terminal = "kitty";` in `local.nix` |
| Change the default browser | `nesw.desktop.hyprland.browser = "firefox";` in `local.nix` |
| Change the UI font (Quickshell, notch, clock) | `nesw.theme.fonts.sansSerif = "Inter";` in `local.nix` |
| Change the terminal font | `nesw.theme.fonts.monospace = "JetBrains Mono";` in `local.nix` |
| Tweak baseline colors (Hyprland borders, scheme) | `nesw.theme.colors.primary = "c4b5fd";` in `local.nix` |
| Live wallpaper-driven colors (no rebuild) | Write JSON to `~/.local/state/nesw/scheme.json` (see Quickshell `Colors.qml`) |
| Add packages or enable programs | Home Manager options in a separate HM-only file, or extend `hosts/laptop/home.nix` |
| Change keybinds or window rules | Edit `modules/desktop/hyprland/config/*.lua` (see [Hyprland Lua Architecture](#hyprland-lua-architecture)) |
| Customize the shell UI (notch, launcher) | Edit QML under `modules/desktop/quickshell/config/` |
| System services, hostname, timezone | `hosts/laptop/configuration.nix` |
| Add a new Home Manager module | `hosts/laptop/home.nix` imports list |

### Example `local.nix`

```nix
{ ... }: {
  nesw.theme.fonts.monospace = "JetBrains Mono";
  nesw.desktop.hyprland.browser = "firefox";
}
```

After saving, rebuild:

```bash
sudo nixos-rebuild switch --flake .#main
```

For the full list of available options, see `modules/themes/default.nix`, `modules/desktop/hyprland/default.nix`, and `hosts/laptop/local.nix.example`.

## Hyprland Lua Architecture

Hyprland is configured in **Lua**, split across focused files under `modules/desktop/hyprland/`. The tree is symlinked into `~/.config/hypr` for fast iteration, while Nix generates the pieces that should be option-driven:

| File | Role |
|------|------|
| `hyprland.lua` | Entry point — loads all `config/*` modules |
| `variables.lua` | **Generated** — default apps, gaps, blur, keybind prefixes |
| `scheme/default.lua` / `scheme/current.lua` | **Generated** — palette from `nesw.theme.colors` |
| `config/keybinds.lua` | Keybindings |
| `config/rules.lua` | Window, workspace, and layer rules |
| `config/general.lua` | Layout, gaps, borders |
| `config/decoration.lua` | Blur and shadow |
| `config/animations.lua` | Animation curves |
| `config/gestures.lua` | Touchpad and workspace swipes |
| `config/input.lua` | Keyboard and touchpad |
| `config/env.lua` | Session environment variables |
| `config/execs.lua` | Autostart (keyring, clipboard, graphical-session target) |
| `config/functions.lua` | Shared bind helpers |
| `config/misc.lua` | Misc compositor settings |

Override default terminal and browser via Nix; tune gaps, rules, and binds in Lua. For a deeper walkthrough of the module layout and Nix bridge, see [modules/desktop/hyprland/README.md](modules/desktop/hyprland/README.md).

Keybinding reference: [KEYBINDINGS.md](KEYBINDINGS.md).

## Project layout

```
nesw/
├── flake.nix                      # inputs, nixosConfigurations.main, homeManagerModules
├── hosts/laptop/
│   ├── default.nix                # host entry (configuration + home)
│   ├── configuration.nix          # NixOS system config
│   ├── home.nix                   # Home Manager imports
│   ├── local.nix.example          # customization template
│   └── hardware-configuration.nix # machine-specific (gitignored)
└── modules/
    ├── themes/                    # nesw.theme.* options
    ├── desktop/
    │   ├── hyprland/              # Hyprland + Lua config
    │   └── quickshell/            # QML shell UI
    ├── shell/                     # fish, starship, tools
    ├── terminal/ghostty/
    ├── editors/nvim/
    └── browser/zen/
```

## Credits & Inspiration

- [Caelesto](https://github.com/caelesto/caelesto) — modular NixOS rice structure and option-driven design
- [end-4](https://github.com/end-4/dots-hyprland) — Hyprland + Quickshell integration patterns
- [Hyprland](https://hyprland.org/) and the Wayland ecosystem
- [NixOS](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) communities

## License

MIT
