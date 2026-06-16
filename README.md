# nesw

![NixOS Unstable](https://img.shields.io/badge/NixOS-unstable-blue?logo=nixos&logoColor=white)
![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-58E1FF?logo=wayland&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

A modular NixOS + Hyprland desktop environment with a Quickshell UI layer, centralized theming, and a Lua config bridge. Designed to be forked, customized via options, and extended without patching core modules.

## ✨ Showcase

![Desktop Preview](./assets/desktop.png)

> Add your own screenshot or GIF at `assets/desktop.png` to show off your setup.

## Features

- **Flake-based multi-host layout** - `hosts/laptop/` with a self-contained `default.nix` entry point, ready to add more machines
- **Dynamic Lua–Hyprland bridge** - `variables.lua` and color scheme files generated from Nix options at build time
- **Centralized theming options** - `nesw.theme.fonts.*` and `nesw.theme.colors.*` drive fonts, Ghostty, Quickshell, and Hyprland borders
- **Quickshell Notch & Border UI** - top bar, rounded screen frame, workspace notch, clock, and app launcher (systemd user service)
- **Home Manager module export** - `homeManagerModules.nesw` for importing into other flakes
- **Fish rebuild helpers** - `nswitch`, `ntest`, `nupdate`, and `nrollback` stage changes and rebuild from `~/nesw`
- **Live color reload** - optional `~/.local/state/nesw/scheme.json` for matugen/wallust without a rebuild

## Quick Start

### Prerequisites

- NixOS with flakes enabled (or willingness to enable them during install)
- A user account that will own the Home Manager profile
- Git (or `nix-shell -p git` on a blank install)

### 1. Clone the repository

```bash
nix-shell -p git   # skip if git is already installed
git clone https://github.com/liammmcauliffe/nesw.git ~/nesw
cd ~/nesw
```

Fish rebuild helpers expect `~/nesw`.

### 2. Copy your hardware configuration

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hosts/laptop/hardware-configuration.nix
```

This file is gitignored so disk UUIDs stay on your machine.

### 3. Set your username

In `flake.nix`, set `userName` to your Linux username (`whoami`):

```nix
userName = "YOUR_USERNAME";
```

**Must match before the first rebuild** - a mismatch can leave you without sudo or Home Manager.

### 4. Create `local.nix` (required)

Every machine needs `hosts/laptop/local.nix`. The build fails without it. Copy the template, then enable **exactly one** GPU driver:

```bash
cp hosts/laptop/local.nix.example hosts/laptop/local.nix
nix-shell -p pciutils --run "lspci -k | grep -A 3 -E 'VGA|3D|Display'"
```

`lspci` is not on a minimal NixOS install - `pciutils` is pulled in via `nix-shell` for this one-off check.

Edit `local.nix`:

```nix
# hosts/laptop/local.nix
{ ... }: {
  nesw.drivers.intel.enable = true;
  # nesw.drivers.amdgpu.enable = true;
  # nesw.drivers.nvidia.enable = true;
}
```

Optional override files (also gitignored):

| File | Imported by | Use for |
|------|-------------|---------|
| `shared.nix` | NixOS + Home Manager | `nesw.theme.*`, `nesw.desktop.hyprland.*` |
| `home.local.nix` | `home.nix` (Home Manager) | `home.packages`, HM-only programs |

```bash
cp hosts/laptop/shared.nix.example hosts/laptop/shared.nix   # optional
```

Do **not** put `nesw.drivers.*` in `shared.nix` or `home.local.nix` - those options exist only on the NixOS side.

Adjust `time.timeZone` and `i18n.defaultLocale` in `hosts/laptop/configuration.nix` if needed.

### 5. Stage gitignored files (required for flakes)

Nix flakes cannot see gitignored files. **Stage them before rebuilding** - you do not need to commit:

```bash
git add -f hosts/laptop/hardware-configuration.nix
git add -f hosts/laptop/local.nix
git add -f hosts/laptop/shared.nix 2>/dev/null
git add -f hosts/laptop/home.local.nix 2>/dev/null
```

After your first successful rebuild, `ntest` / `nswitch` force-stage these paths automatically.

### 6. Build safely (first time)

Use `test` for the first apply - reboot reverts if something breaks:

```bash
sudo NIX_CONFIG='experimental-features = nix-command flakes' \
  nixos-rebuild test --flake .#main
```

When satisfied, make it permanent:

```bash
sudo nixos-rebuild switch --flake .#main
```

Reboot, log into a TTY, and start Hyprland:

```bash
Hyprland
```

### 7. Day-to-day rebuilds

From any directory (Fish, after HM is active):

```bash
nswitch    # stage changes, rebuild and switch
ntest      # test build (reverted on reboot)
nupdate    # update flake inputs, test build
nrollback  # switch to previous system generation
```

## Disaster recovery

If a rebuild breaks your system, Hyprland won't start, or you get stuck, don't panic.

### Case 1: System boots, but Hyprland is broken

1. Reboot.
2. At the `systemd-boot` menu, select an older NixOS generation.
3. Boot into it - you're in a working state.
4. Fix the issue in your config, or run `nrollback` to make that generation the default.

### Case 2: UI freezes while logged in

1. Switch to a TTY: `Ctrl+Alt+F2` (or F3, F4…).
2. Log in with your username and password.
3. Run `sync`, then `kill-ui` to stop Quickshell and Hyprland.
4. Run `Hyprland`, or `systemctl --user start graphical-session.target`.

### Case 3: `nswitch` fails with staged broken changes

Because `nswitch` stages changes before rebuilding, broken edits may be staged but not committed.

1. From a TTY: `cd ~/nesw && git reset HEAD .`
2. Run `nrollback` to return to the last working system generation.
3. Fix your files and try again.

### Generations and Home Manager

`nrollback` rolls back the **system** configuration only. If a Home Manager change broke your user session, fix the Nix code and rebuild - or boot an older system generation that still has a working HM profile.

```bash
nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Customization

Defaults live in `modules/`; machine-specific choices go in `local.nix`, `shared.nix`, or `home.local.nix`. Options use `lib.mkDefault`, so overrides win without patching core modules.

### Where to edit what

| You want to… | Do this |
|--------------|---------|
| Enable GPU / VA-API / Vulkan | `nesw.drivers.*.enable` in `local.nix` |
| Change the default terminal | `nesw.desktop.hyprland.terminal` in `shared.nix` |
| Change the default browser | `nesw.desktop.hyprland.browser` in `shared.nix` |
| Change UI or terminal fonts | `nesw.theme.fonts.*` in `shared.nix` |
| Tweak baseline colors (Hyprland borders) | `nesw.theme.colors.*` in `shared.nix` |
| Live wallpaper-driven colors (no rebuild) | `~/.local/state/nesw/scheme.json` (see Quickshell `Colors.qml`) |
| Add user packages / HM programs | `home.local.nix` or `hosts/laptop/home.nix` |
| Change keybinds or window rules | `modules/desktop/hyprland/config/*.lua` |
| Customize the shell UI (notch, launcher) | `modules/desktop/quickshell/config/` |
| System services, hostname, timezone | `hosts/laptop/configuration.nix` or `local.nix` |

### Example `shared.nix`

```nix
{ ... }: {
  nesw.theme.fonts.monospace = "JetBrains Mono";
  nesw.desktop.hyprland.browser = "firefox";
}
```

### Example `local.nix`

```nix
{ ... }: {
  nesw.drivers.intel.enable = true;
  time.timeZone = "America/Los_Angeles";
}
```

After saving, rebuild with `ntest` or `nswitch`.

Option reference: `modules/themes/default.nix`, `modules/desktop/hyprland/default.nix`, `modules/drivers/default.nix`, and `hosts/laptop/local.nix.example`.

## Hyprland Lua architecture

Hyprland is configured in **Lua** under `modules/desktop/hyprland/`. Home Manager deploys the tree to `~/.config/hypr/`; Nix generates option-driven files at build time:

| File | Role |
|------|------|
| `hyprland.lua` | Entry point - loads all `config/*` modules |
| `variables.lua` | **Generated** - default apps, gaps, blur, keybind prefixes |
| `scheme/default.lua` / `scheme/current.lua` | **Generated** - palette from `nesw.theme.colors` |
| `config/keybinds.lua` | Keybindings |
| `config/rules.lua` | Window, workspace, and layer rules |
| `config/execs.lua` | Autostart (keyring, clipboard, `graphical-session.target`) |
| `config/env.lua` | Session environment variables |

Quickshell runs as `systemd --user` service `quickshell` (`qs -c nesw`), config at `~/.config/quickshell/nesw/`.

See [modules/desktop/hyprland/README.md](modules/desktop/hyprland/README.md) and [KEYBINDINGS.md](KEYBINDINGS.md).

## Project layout

```
nesw/
├── flake.nix                      # inputs, nixosConfigurations.main, homeManagerModules
├── hosts/laptop/
│   ├── default.nix                # host entry (configuration + home paths)
│   ├── configuration.nix          # NixOS system config
│   ├── home.nix                   # Home Manager entry
│   ├── local.nix.example          # override template
│   ├── local.nix                  # required - NixOS overrides (gitignored)
│   ├── shared.nix                 # shared overrides (gitignored)
│   ├── home.local.nix             # HM-only overrides (gitignored)
│   └── hardware-configuration.nix # machine-specific (gitignored)
└── modules/
    ├── themes/                    # nesw.theme.* options
    ├── drivers/                   # nesw.drivers.* (GPU / Mesa / VA-API)
    ├── desktop/                   # hyprland, quickshell
    ├── shell/                     # fish, starship, tools
    ├── terminal/ghostty/
    ├── editors/nvim/
    └── browser/zen/
```

## Credits & Inspiration

- [Caelesto](https://github.com/caelesto/caelesto) - modular NixOS rice structure and option-driven design
- [end-4](https://github.com/end-4/dots-hyprland) - Hyprland + Quickshell integration patterns
- [Hyprland](https://hyprland.org/) and the Wayland ecosystem
- [NixOS](https://nixos.org/) and [Home Manager](https://github.com/nix-community/home-manager) communities

## License

MIT
