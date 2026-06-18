# Quickshell Module

**Decision: Path A** — `matugen` is packaged in nixpkgs; a thin `nesw-recolor` wrapper adapts its JSON output to the `Colors.qml` contract with `jq`.

Quickshell UI for nesw (notch, border, clock, launcher, logout dialog). Config lives in `config/` and deploys to `~/.config/quickshell/nesw/`. Runs as the `quickshell` systemd user service (`qs -c nesw`).

## Live color reload (`scheme.json`)

### What `Colors.qml` does

`Colors.qml` reads `~/.local/state/nesw/scheme.json`, hot-reloads on change, and overrides the default `nesw.theme.colors` palette in the Quickshell UI **without a rebuild**. Hyprland border colors still come from rebuild-time `scheme/*.lua`; live reload is QML-only.

The state directory is pre-created at `~/.local/state/nesw/` via Home Manager (`.keep` file in `default.nix`).

### JSON contract

Parsed by `Colors.qml` `load()` (`modules/desktop/quickshell/config/Colors.qml`):

- Top-level may be `{ "colors": { ... } }`, `{ "colours": { ... } }`, or a flat `{ ... }`.
- Keys are Material 3 role names **without** the `m3` prefix. They map to `m3<name>` on the `Palette` QtObject (e.g. `primary` → `m3primary`).
- Values are `rrggbb` or `#rrggbb`. Unknown keys are ignored.
- Valid roles (from `Palette`):

| Role | Role | Role |
|------|------|------|
| `primary` | `onPrimary` | `primaryContainer` |
| `onPrimaryContainer` | `secondary` | `onSecondary` |
| `secondaryContainer` | `onSecondaryContainer` | `tertiary` |
| `onTertiary` | `background` | `onBackground` |
| `surface` | `onSurface` | `surfaceContainerLowest` |
| `surfaceContainerLow` | `surfaceContainer` | `surfaceContainerHigh` |
| `surfaceContainerHighest` | `surfaceVariant` | `onSurfaceVariant` |
| `outline` | `outlineVariant` | `error` |
| `onError` | `shadow` | `scrim` |

### Example

```json
{ "colors": { "primary": "c4b5fd", "surface": "1e1b2e", "onSurfaceVariant": "a1a1aa" } }
```

### How to generate

Run manually after changing wallpaper (no auto-trigger in this spike):

```bash
nesw-recolor /path/to/wallpaper.png
```

This runs `matugen image <wallpaper> -m dark --json hex_stripped`, converts matugen's snake_case `dark` palette keys to camelCase, wraps them in `{ "colors": { ... } }`, and writes `~/.local/state/nesw/scheme.json`. Quickshell picks up the change via `FileView` `watchChanges`.

**Bring-your-own alternative:** install matugen or wallust yourself and configure output to write `~/.local/state/nesw/scheme.json` in the shape above (camelCase keys, no `m3` prefix).

### Open questions

- Should rebuild-time `nesw.theme.colors` and live `scheme.json` share one source file?
- Auto-regenerate on wallpaper change (systemd path unit) — deferred; `nesw-recolor` is the intended `ExecStart` when that lands.
- Wallpaper picker UI — deferred.
