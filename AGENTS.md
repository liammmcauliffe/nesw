# AGENTS.md

Orientation for coding agents working on nesw. Read this before editing. For user-facing setup, customization, and disaster recovery, see [README.md](./README.md).

## What this is

A NixOS + Hyprland desktop configuration, packaged as a flake. Hyprland is configured in Lua; the shell UI (notch, border, clock, launcher, logout dialog) is Quickshell QML. Defaults live in `modules/`; machine-specific overrides live in gitignored host files under `hosts/<name>/` (today: `hosts/laptop/`, flake target `.#main`).

Module READMEs: [modules/desktop/hyprland/README.md](modules/desktop/hyprland/README.md), [modules/desktop/quickshell/README.md](modules/desktop/quickshell/README.md). Keybind reference: [KEYBINDINGS.md](KEYBINDINGS.md).

## Build & verify

| Purpose | Command |
|---------|---------|
| Flake check (CI gate) | `nix flake check` |
| Dry-build the system toplevel | `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` |
| Lua style check | `stylua --check modules` (config: `.stylua.toml` — column 120, 2-space indent) |

CI runs `flake` and `stylua` jobs in parallel (`.github/workflows/check.yml`). `nix flake check` is the primary gate. If `hosts/laptop/hardware-configuration.nix` is missing (gitignored), copy the example first: `cp hosts/laptop/hardware-configuration.nix.example hosts/laptop/hardware-configuration.nix` (CI does this automatically).

There is no unit-test suite. Correctness is verified by `nix flake check` + dry-build + `stylua --check` on Lua.

## Generated files — never hand-edit

These are written at build time from Nix. Edit the Nix source, not the output:

- `~/.config/hypr/variables.lua` — from `variablesLua` in `modules/desktop/hyprland/default.nix`
- `~/.config/hypr/scheme/default.lua`, `scheme/current.lua` — from `schemeLua` in the same file
- `~/.config/quickshell/nesw/Fonts.qml` — from `fontsQml` in `modules/desktop/quickshell/default.nix`

The Hyprland Lua tree is **copied** (not symlinked) to `~/.config/hypr/` via `runCommand` in `modules/desktop/hyprland/default.nix`. Edits to repo `config/*.lua` take effect on the next rebuild.

## Live runtime files (not generated at build)

- `~/.local/state/nesw/scheme.json` — Quickshell live palette override; hot-reloaded by `Colors.qml`. Generate with `nesw-recolor <wallpaper>` or write manually. Contract: [modules/desktop/quickshell/README.md](modules/desktop/quickshell/README.md).
- `~/.local/state/nesw/launcher-history.json` — launcher frequency history; written by `Launcher.qml` via `FileView.setText()` (no shell-out).

## Override mechanism

- Defaults: `modules/` (use plain `default =` for option defaults; `mkDefault` only where a host override is expected to win).
- Per-host gitignored files under `hosts/<name>/` (today `hosts/laptop/`):
  - `local.nix` (NixOS-only): `nesw.drivers.*`, system settings
  - `shared.nix` (NixOS + Home Manager): `nesw.theme.*`, `nesw.desktop.hyprland.*`
  - `home.local.nix` (Home Manager only): `home.packages`, HM programs
  - `hardware-configuration.nix` (NixOS-only, machine-specific)

`nesw.drivers.*` is NixOS-only — never put it in `shared.nix` or `home.local.nix`. Enable exactly one of `amdgpu`/`intel`/`nvidia` (assertion in `modules/drivers/default.nix`).

**Hostname convention:** `networking.hostName` must match the flake target name (`.#main` today). Host directory name should match hostname when possible; the fish helpers fall back to the sole `hosts/*` entry if `hosts/$NESW_HOST` does not exist.

## Hard constraints

- `networking.hostName` must match the flake target (assertion in `hosts/laptop/configuration.nix`; hardcoded `"main"` today).
- `userName` in `flake.nix` must match the real Linux username.
- Flakes cannot see gitignored files. Fish helpers force-stage host override files via `_nesw_stage` (uses `$NESW_HOST_DIR`). For a manual first build: `git add -f hosts/laptop/{hardware-configuration,local,shared,home.local}.nix`.

## Conventions

- Every module dir has a `default.nix` with a `/* ... */` header: what it does, `Exposes:`, `Depends:`. See `modules/shell/starship/default.nix` (minimal) and `modules/desktop/hyprland/default.nix` (maximal: options + generated files).
- Aggregators: `imports = [ ./child ... ]` in the category `default.nix`. Top-level aggregator is `modules/nesw.nix` (`nesw.enable = true`).
- Adding a module: create `modules/<category>/<name>/default.nix` with a header, import it from `modules/<category>/default.nix`.
- Fish helpers live in `modules/shell/fish/functions/`. `_nesw_repo` enters the repo; `_nesw_stage` stages changes.
- QML lives in `modules/desktop/quickshell/config/`; `shell.qml` lists each top-level surface. Quickshell IPC toggles: `qs ipc call launcher toggle`, `qs ipc call logout toggle`.

## Rebuild helpers (Fish)

`nswitch` (rebuild + switch), `ntest` (test build, reverts on reboot), `nupdate` (update flake inputs + test), `nrollback` (previous system generation, no repo path). Run from any directory after Home Manager is active.

Derived by `_nesw_repo` on each call:

| Var | Resolution |
|-----|------------|
| `$NESW_DIR` | Shell env override for repo path; default `~/nesw` |
| `$NESW_HOST` | `hostnamectl` / `hostname` / `/etc/hostname` → flake target `.#$NESW_HOST` |
| `$NESW_HOST_DIR` | Shell env override; else `hosts/$NESW_HOST`; else sole `hosts/*` entry |

`nesw-recolor <wallpaper>` — manual wallpaper → `scheme.json` (matugen + jq); see quickshell README.
