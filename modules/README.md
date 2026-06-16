# nesw modules

nesw is organized by concern so each piece stays small, testable, and overridable. The flake wires hosts under `hosts/`; everything users customize lives in modules here.

## How it fits together

**`themes/`** defines `nesw.theme.*` - font families and baseline colors. NixOS reads these in `hosts/laptop/configuration.nix` for `fonts.packages`; Home Manager modules read the same options for Ghostty, Quickshell, and Hyprland.

**`desktop/`** is the Wayland shell layer. `hyprland/` symlinks a Lua config tree and **generates** `variables.lua` and `scheme/*.lua` from Nix options (`nesw.desktop.hyprland.*`, `nesw.theme.colors.*`). `quickshell/` provides the notch, border, clock, and launcher QML UI.

**`shell/`**, **`terminal/`**, **`editors/`**, and **`browser/`** wrap Fish, Starship, CLI tools, Ghostty, Neovim, and Zen Browser. They depend on `themes/` where fonts matter.

The top-level **`nesw.nix`** aggregator imports all of the above when `nesw.enable = true`. Host configs only need that one import plus overrides in `local.nix`.

## Nix → Lua bridge

Hyprland is configured in Lua for fast iteration, but user-facing defaults (terminal, browser, colors) are Nix options so `local.nix` can override them without editing Lua. At build time, `modules/desktop/hyprland/default.nix` writes:

- `~/.config/hypr/variables.lua` - apps, gaps, keybind prefixes
- `~/.config/hypr/scheme/default.lua` and `scheme/current.lua` - palette from `nesw.theme.colors`

The rest of `config/*.lua` is symlinked from the repo. Edit those files for keybinds, rules, and gestures.

## How to add a new module

1. **Pick a category** - e.g. `modules/shell/my-tool/` or create a new parent if needed.
2. **Add `default.nix`** - Home Manager (or NixOS) config; declare `nesw.<category>.<name>.*` options if users should override behavior.
3. **Import it** - add `./my-tool` to the category's `default.nix` (e.g. `modules/shell/default.nix`).
4. **Document** - a short header comment in `default.nix` (what it does, options, depends).

If the module introduces new top-level options, ensure `modules/themes/default.nix` or the relevant domain module defines them with `lib.mkDefault` so `local.nix` overrides work.

## Importing nesw from another flake

```nix
# In your home-manager user config:
imports = [ inputs.nesw.homeManagerModules.nesw ];

nesw.home-manager.enable = true;
# or: nesw.enable = true;

nesw.theme.fonts.monospace = "JetBrains Mono";
```

NixOS-side fonts still need `nesw.theme` options in scope - import `inputs.nesw + "/modules/themes"` in your system configuration, or share a `local.nix` that sets `nesw.theme.*`.

## Layout

```
modules/
├── nesw.nix              # top-level aggregator (nesw.enable)
├── home-manager.nix      # flake export for external consumers
├── themes/
├── desktop/              # hyprland, quickshell
├── shell/                # fish, starship, tools
├── terminal/             # ghostty
├── editors/              # nvim
└── browser/              # zen
```
