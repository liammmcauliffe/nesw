# nesw

NixOS + Hyprland setup

## Project layout

```
nesw/
├── flake.nix                 # flake inputs + home-manager user
├── hosts/main/
│   ├── configuration.nix     # system config (hostname, audio, hyprland, user)
│   ├── home.nix              # imports all home-manager modules
│   └── hardware-configuration.nix
└── modules/
    ├── hyprland/             # Hyprland Lua config (see below)
    ├── quickshell/           # QML shell (Notch, Border, Colors)
    ├── fish/                 # shell aliases + rebuild helpers
    ├── ghostty/
    ├── nvim/
    ├── starship/
    ├── tools/                # eza, zoxide, broot
    └── zen/
```

### Hyprland config

Hyprland is configured in Lua, split across `modules/hyprland/`:

| File | Purpose |
|------|---------|
| `hyprland.lua` | Entry point - loads all config modules |
| `variables.lua` | Apps, gaps, blur, keybind modifiers |
| `config/keybinds.lua` | Keybindings |
| `config/rules.lua` | Window and workspace rules |
| `config/gestures.lua` | Touchpad gestures |
| `config/animations.lua` | Animation curves |
| `config/general.lua` | Layout, gaps, borders |
| `config/decoration.lua` | Blur and shadow |
| `config/input.lua` | Keyboard and touchpad |
| `config/env.lua` | Environment variables |
| `config/execs.lua` | Autostart (keyring, clipboard, quickshell, etc.) |
| `config/functions.lua` | Shared bind helpers |
| `config/misc.lua` | Misc Hyprland options |

### Quickshell

`modules/quickshell/config/shell.qml` loads:

- **TopBar** — blurred top band
- **Border** — rounded screen frame overlay
- **Notch** — animated workspace indicator with scroll/tap to switch
- **Clock** — top-right date and time
- **Launcher** — app launcher (`SUPER + space`, or `qs ipc call launcher toggle`)

**Colors** is a singleton that hot-reloads a Material 3 palette from `~/.local/state/nesw/scheme.json` (optional; defaults are baked in). Write `colors` or `colours` keys — both work for external tools like matugen/wallust.

**Fonts** — Quickshell uses DM Sans, installed system-wide via `fonts.packages` in `hosts/main/configuration.nix`.

## Fresh install

### 1. Get git

On a fresh NixOS system without git:

```bash
nix-shell -p git
```

### 2. Clone to ~/nesw

```bash
git clone https://github.com/liammmcauliffe/nesw.git ~/nesw
cd ~/nesw
```

### 3. Copy hardware config

```bash
sudo cp /etc/nixos/hardware-configuration.nix ./hosts/main/hardware-configuration.nix
```

### 4. Set your username

Replace `"liam"` in both places, or you will lose sudo access on first boot:

**`flake.nix`**

```nix
home-manager.users."YOUR_USERNAME" = {
```

**`hosts/main/configuration.nix`**

```nix
users.users."YOUR_USERNAME" = {
```

While you are in `configuration.nix`, adjust `time.timeZone` and `i18n.defaultLocale` if needed. To use a different hostname, change `networking.hostName` and the flake target (`nixosConfigurations.main` → your name, then rebuild with `.#yourname`).

### 5. Apply

```bash
sudo nixos-rebuild switch --flake .#main
```

Reboot, log into a TTY, and start Hyprland:

```bash
Hyprland
```

### 6. Commit machine-specific changes

Commit your username, hardware config, and any locale/timezone edits so a re-clone does not wipe them.

## Day-to-day

### Rebuild from anywhere (fish)

```bash
nswitch   # git add -A, nixos-rebuild switch --flake ~/nesw#main
ntest     # same, but nixos-rebuild test
```

### Default keybinds

Defined in `modules/hyprland/variables.lua` and `config/keybinds.lua`. Highlights:

| Binding | Action |
|---------|--------|
| `SUPER + Return` | Terminal (ghostty) |
| `SUPER + W` | Browser (zen-beta) |
| `SUPER + space` | App launcher |
| `SUPER + 1–0` | Focus workspace |
| `SUPER + CTRL + 1–0` | Move window to workspace |
| `SUPER + S` | Toggle special workspace |
| `SUPER + Q` | Close window |
| `SUPER + SHIFT + L` | Suspend |

Volume keys and `SUPER + SHIFT + M` control PipeWire via `wpctl`.

### Where to edit what

| Change | File |
|--------|------|
| Apps, gaps, blur, keybind prefixes | `modules/hyprland/variables.lua` |
| Keybindings | `modules/hyprland/config/keybinds.lua` |
| Window rules | `modules/hyprland/config/rules.lua` |
| Autostart | `modules/hyprland/config/execs.lua` |
| Notch / border UI | `modules/quickshell/config/` |
| Color scheme output path | `modules/quickshell/config/Colors.qml` |
| Neovim | `modules/nvim/config/` |
| Terminal | `modules/ghostty/default.nix` |
| Fish / rebuild helpers | `modules/fish/config.fish` |
| Starship prompt | `modules/starship/starship.toml` |
| System packages / services | `hosts/main/configuration.nix` |
| Add a home-manager module | `hosts/main/home.nix` |

## Flake inputs

- [nixpkgs](https://github.com/nixos/nixpkgs) — `nixos-unstable`
- [Hyprland](https://github.com/hyprwm/Hyprland)
- [home-manager](https://github.com/nix-community/home-manager)
- [zen-browser-flake](https://github.com/0xc000022070/zen-browser-flake)
- [quickshell](https://git.outfoxxed.me/outfoxxed/quickshell)
