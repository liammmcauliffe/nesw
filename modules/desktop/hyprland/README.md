# Hyprland Module

Hyprland compositor configuration for nesw. Lua sources live in this directory and are symlinked to `~/.config/hypr` for rapid iteration.

## Nix bridge

These files are **generated at build time** from Nix options - do not edit them in the repo:

- `variables.lua` - from `nesw.desktop.hyprland.*` (terminal, browser, gaps, keybind prefixes)
- `scheme/default.lua` and `scheme/current.lua` - from `nesw.theme.colors.*`

Override apps and colors in `hosts/laptop/local.nix`:

```nix
nesw.desktop.hyprland.terminal = "ghostty";
nesw.theme.colors.primary = "e4e4e7";
```

## Lua layout

| Path | Purpose |
|------|---------|
| `hyprland.lua` | Entry point |
| `config/keybinds.lua` | Keybindings |
| `config/rules.lua` | Window and workspace rules |
| `config/general.lua` | Layout and gaps |
| `config/decoration.lua` | Blur and shadow |
| `config/animations.lua` | Motion curves |
| `config/gestures.lua` | Touchpad gestures |
| `config/input.lua` | Keyboard and touchpad |
| `config/env.lua` | Environment variables (`NESW_DIR`) |
| `config/execs.lua` | Autostart (Quickshell, cliphist, keyring) |
| `config/functions.lua` | Shared helpers for binds |
| `config/misc.lua` | Misc compositor options |

## `NESW_DIR`

Lua configs resolve the repo via `NESW_DIR` (defaults to `~/nesw`). Set it in `config/env.lua` or your environment if the clone lives elsewhere.

Full keybinding reference: [KEYBINDINGS.md](../../../KEYBINDINGS.md) in the repo root.
