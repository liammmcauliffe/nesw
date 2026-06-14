# nesw

NixOS + Hyprland setup

## Project layout

```
nesw/
├── flake.nix                 # flake inputs + home-manager user
├── hosts/main/
│   ├── configuration.nix     # system config (hostname, audio, hyprland, user)
│   ├── home.nix              # imports all home-manager modules
│   ├── local.nix.example     # optional local overrides schema
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

See [KEYBINDINGS.md](KEYBINDINGS.md) for the full keybinding reference.

### Quickshell

`modules/quickshell/config/shell.qml` loads:

- **TopBar** — blurred top band
- **Border** — rounded screen frame overlay
- **Notch** — animated workspace indicator with scroll/tap to switch
- **Clock** — top-right date and time
- **Launcher** — app launcher (`SUPER + space`, or `qs ipc call launcher toggle`)

**Fonts** — Quickshell uses DM Sans, installed system-wide via `fonts.packages` in `hosts/main/configuration.nix`.

## Colors

Quickshell reads a Material 3 palette from `~/.local/state/nesw/scheme.json`. The file is optional — dark zinc defaults are baked into `Colors.qml` when it is missing.

The JSON shape is `{ "colors": { "primary": "rrggbb", ... } }`. External tools may use `"colours"` instead of `"colors"`; both work. Keys may include or omit a `#` prefix and an `m3` prefix.

To generate a scheme:

1. Point [matugen](https://github.com/InioX/matugen) or [wallust](https://codeberg.org/explosion-mental/wallust) at your wallpaper.
2. Configure the tool to write JSON to `~/.local/state/nesw/scheme.json` (create the directory if needed).
3. Quickshell hot-reloads the file when it changes — no rebuild required.

## Fresh install

> **Important:** Before your first `nixos-rebuild`, set `userName` in `flake.nix` to your actual Linux username. If it does not match your account, you can lose sudo access on first boot.

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

In `flake.nix`, change the `userName` variable near the top of the `let` block:

```nix
userName = "YOUR_USERNAME";
```

This value is passed to both home-manager and `hosts/main/configuration.nix` automatically.

While you are editing config, adjust `time.timeZone` and `i18n.defaultLocale` in `hosts/main/configuration.nix` if needed. To use a different hostname, change `networking.hostName` and the flake target (`nixosConfigurations.main` → your name, then rebuild with `.#yourname`).

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

### Rebuild helpers (Fish)

Defined in `modules/fish/config.fish`. Both stage all changes in `~/nesw`, run a rebuild, and return you to your previous directory even if the rebuild fails.

```bash
nswitch   # git add -A, nixos-rebuild switch --flake ~/nesw#main
ntest     # same, but nixos-rebuild test (temporary, rolled back on reboot)
```

### Default keybinds

Defined in `modules/hyprland/variables.lua` and `config/keybinds.lua`. See [KEYBINDINGS.md](KEYBINDINGS.md) for the full list. Highlights:

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
| Machine-specific overrides | `hosts/main/local.nix` (copy from `local.nix.example`) |

## Troubleshooting / FAQ

### Hyprland does not start

- Run `Hyprland` from a TTY and read the error output.
- Confirm the flake rebuilt successfully: `sudo nixos-rebuild switch --flake ~/nesw#main`.
- Check that `~/.config/hypr/hyprland.lua` exists (symlinked by home-manager from `modules/hyprland/`).
- If Lua errors mention missing modules, ensure the repo lives at `~/nesw` or set `NESW_DIR` in `modules/hyprland/config/env.lua`.

### Quickshell is missing or crashes

- Quickshell is started from `modules/hyprland/config/execs.lua` using `NESW_DIR` (defaults to `~/nesw`).
- Run manually to see errors: `qs -p ~/nesw/modules/quickshell/config`.
- After a home-manager rebuild, the config is also copied to `~/.config/quickshell` — either path should work.

### Fonts not rendering (notch, clock, launcher)

- DM Sans must be installed system-wide. It is declared in `fonts.packages` inside `hosts/main/configuration.nix`.
- Rebuild and log out/in: `nswitch`.
- Verify the font is available: `fc-list | grep -i "dm sans"`.

### Colors not updating

- Confirm `~/.local/state/nesw/scheme.json` exists and is valid JSON.
- Check file permissions — Quickshell watches the file for changes.
- Keys should map to Material 3 names (`primary`, `onSurface`, etc.) or `m3`-prefixed variants.

### Rebuild failed mid-way

- Fish helpers always `cd` back to your original directory, even on failure.
- Fix the Nix error, then run `nswitch` or `ntest` again.

## Flake inputs

- [nixpkgs](https://github.com/nixos/nixpkgs) — `nixos-unstable`
- [Hyprland](https://github.com/hyprwm/Hyprland)
- [home-manager](https://github.com/nix-community/home-manager)
- [zen-browser-flake](https://github.com/0xc000022070/zen-browser-flake)
- [quickshell](https://git.outfoxxed.me/outfoxxed/quickshell)
