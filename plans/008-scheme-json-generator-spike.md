# Plan 008: Wire a wallpaper → `scheme.json` color generator (design/spike)

> **Executor instructions**: This is a **design + spike plan**. The goal is to decide whether and how to ship a wallpaper-driven color generator that writes `~/.local/state/nesw/scheme.json`, prototype the thinnest end-to-end path, and document the contract `Colors.qml` already expects — then stop. Do not over-build. Run verification gates. If anything in the "STOP conditions" occurs, stop and report. When done, update the status row in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 17b661a..HEAD -- modules/desktop/quickshell/config/Colors.qml modules/desktop/quickshell/default.nix README.md`
> If these changed, re-read them before proceeding.

## Status

- **Priority**: P3
- **Effort**: M (design) / L (full build — this plan does the design + thinnest spike only)
- **Risk**: MED
- **Depends on**: none
- **Category**: direction
- **Planned at**: commit `17b661a`, 2026-06-17
- **Issue**: (not published)

## Why this matters

`README.md` advertises "Live wallpaper-driven colors (no rebuild)" via `~/.local/state/nesw/scheme.json`, and `Colors.qml` already watches that file and re-applies it live. But **nothing in the repo writes `scheme.json`** — the feature is half-built and only works if the user manually installs and runs an external generator (matugen/wallust) and points it at the right path. This plan decides: ship a minimal generator module, or honestly downgrade the README to "bring-your-own." Either way the current state — a headline feature that does nothing out of the box — is resolved.

## Current state

`modules/desktop/quickshell/config/Colors.qml` (singleton):

- `schemePath = ${Quickshell.env("HOME")}/.local/state/nesw/scheme.json`
- A `FileView` with `watchChanges: true`, `printErrors: false`, `onFileChanged: reload()`, `onLoaded: root.load(text())`.
- `load(data)` parses JSON, accepts `{ "colors": { "primary": "rrggbb" } }`, British `colours`, or flat keys; strips optional leading `#`; only applies properties defined on the `Palette` QtObject (`m3primary`, `m3onSurface`, `m3surface`, `m3onSurfaceVariant`, …).
- Default `Palette` values match `nesw.theme.colors` (zinc palette).

So the **contract** `Colors.qml` expects: a JSON file at `schemePath` whose top-level (or `.colors`/`.colours`) object maps M3 role names (without the `m3` prefix) to `rrggbb` or `#rrggbb` strings. Unknown keys are ignored. The file is hot-reloaded on change.

`modules/desktop/quickshell/default.nix` pre-creates `~/.local/state/nesw/` via `home.file.".local/state/nesw/.keep".text = ""`.

`README.md` "Live color reload" bullet and the customization table row point here. `modules/themes/default.nix` defines `nesw.theme.colors.*` (the rebuild-time defaults) but has no live-reload hook.

No generator (matugen, wallust, pywal) is in the flake inputs or `home.packages` anywhere.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Build | `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` | exit 0 |
| Flake check | `nix flake check` | exit 0 |
| Contract doc exists | `grep -n "scheme.json" modules/desktop/quickshell/README.md` (created in this plan) | match |

## Scope

**In scope** (this plan = design + thinnest spike):
- `modules/desktop/quickshell/README.md` (create or extend) — document the `scheme.json` contract.
- One of:
  - (A) A minimal Nix module + script that runs an existing generator (e.g. matugen) on a wallpaper path and writes `scheme.json` in the `Colors.qml` format. **OR**
  - (B) If (A) is too heavy for a spike, just write the `README.md` contract + a tiny example `scheme.json` and downgrade the README "feature" bullet to "bring-your-own (docs inside)." 
- `README.md` root — align the "Live color reload" bullet with whichever path is chosen.

**Out of scope** (defer to a follow-up build plan):
- A wallpaper-picker UI.
- Caching/regeneration triggers on wallpaper change (systemd path units, etc.) beyond the spike.
- Generating the Hyprland `scheme/*.lua` from the same source (that's rebuild-time; live reload is QML-only by design).
- New flake inputs unless the spike specifically needs one (and only with operator sign-off — see STOP conditions).

## Git workflow

- Branch: `advisor/008-scheme-json-generator-spike`
- Commit: `spike: scheme.json contract + minimal generator` (or `docs: scheme.json bring-your-own contract` if path B)
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Decide path A vs B

Investigate the cost of path A by checking what's available in nixpkgs:

```
nix eval nixpkgs#matugen.meta.description 2>/dev/null
nix eval nixpkgs#wallust.meta.description 2>/dev/null
```

(If neither is packaged, path A requires a flake input — that's scope expansion; default to path B and report.)

**Decision rule**:
- If a generator is in nixpkgs **and** can output the `Colors.qml` JSON shape (or a small wrapper script can adapt its output), choose **path A**.
- Otherwise choose **path B** (document the contract, downgrade the README bullet, ship an example `scheme.json`).

Record the decision and its one-line rationale at the top of the new `modules/desktop/quickshell/README.md`.

### Step 2: Document the `scheme.json` contract

Create `modules/desktop/quickshell/README.md` (the quickshell module has no README yet). Include:

1. **What `Colors.qml` does**: reads `~/.local/state/nesw/scheme.json`, hot-reloads on change, overrides the default `nesw.theme.colors` palette live (no rebuild).
2. **The JSON contract** (the load-bearing spec, quoted from `Colors.qml`'s `load()`):
   - Top-level may be `{ "colors": { ... } }`, `{ "colours": { ... } }`, or a flat `{ ... }`.
   - Keys are M3 role names **without** the `m3` prefix: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`, `tertiary`, `onTertiary`, `background`, `onBackground`, `surface`, `onSurface`, `surfaceContainerLowest`…`Highest`, `surfaceVariant`, `onSurfaceVariant`, `outline`, `outlineVariant`, `error`, `onError`, `shadow`, `scrim`. (Full list from `Colors.qml`'s `Palette` QtObject.)
   - Values are `rrggbb` or `#rrggbb`. Unknown keys are ignored.
3. **Example** (valid against `Colors.qml`):
   ```json
   { "colors": { "primary": "c4b5fd", "surface": "1e1b2e", "onSurfaceVariant": "a1a1aa" } }
   ```
4. **How to feed it** (path-dependent):
   - Path A: the shipped generator command + how to point it at a wallpaper.
   - Path B: "install matugen/wallust yourself, configure it to write `~/.local/state/nesw/scheme.json` in the shape above."

**Verify**: `test -f modules/desktop/quickshell/README.md && echo ok` → `ok`.

### Step 3: (Path A only) Thinnest generator spike

If path A: add a minimal Nix module — either a new `modules/desktop/quickshell/generator.nix` or a small addition to `modules/desktop/quickshell/default.nix` — that:

- Pulls the chosen generator from `pkgs`.
- Ships a script (e.g. `nesw-recolor <wallpaper-path>`) that runs the generator and writes `~/.local/state/nesw/scheme.json` in the `Colors.qml` shape (adapting the generator's output format with `jq` if needed — `jq` is already in `home.packages` via `modules/shell/tools/default.nix`).
- Does **not** auto-run on wallpaper change (that's deferred). Manual run only for the spike.

Keep it under ~40 lines of Nix + script. No new flake input (use nixpkgs only).

If path B: skip this step; the README contract + example is the deliverable.

**Verify**: `nix flake check` → exit 0. `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` → exit 0.

### Step 4: Align `README.md` root bullet

Update the "Live color reload" bullet in `README.md` Features and the customization table row to match the chosen path:

- Path A: "Live wallpaper-driven colors (no rebuild) — run `nesw-recolor <wallpaper>`; see `modules/desktop/quickshell/README.md` for the `scheme.json` contract."
- Path B: "Live color reload (bring-your-own generator) — point matugen/wallust at `~/.local/state/nesw/scheme.json`; see `modules/desktop/quickshell/README.md` for the contract."

**Verify**: `grep -n "scheme.json" README.md` → matches reference `modules/desktop/quickshell/README.md`.

### Step 5: Build

**Verify**: `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` → exit 0.
**Verify**: `nix flake check` → exit 0.

## Test plan

No unit tests. Verification:
- `modules/desktop/quickshell/README.md` exists and documents the contract; the example JSON is valid against `Colors.qml`'s `load()` (manual trace: keys exist in `Palette`, values are `rrggbb`).
- (Path A) the generator script produces a `scheme.json` that `Colors.qml` accepts (manual runtime: run it, confirm `qs` reloads colors).
- `README.md` bullet matches the shipped reality.
- Build passes.

## Done criteria

- [ ] `modules/desktop/quickshell/README.md` exists with the `scheme.json` contract + example
- [ ] Decision (path A or B) recorded at the top of that README with a one-line rationale
- [ ] (Path A) a `nesw-recolor` script (or equivalent) exists and builds; (Path B) no script, README-only
- [ ] `README.md` "Live color reload" bullet matches the chosen path and links the contract
- [ ] `nix flake check` and `nix build ... toplevel` exit 0
- [ ] Only in-scope files modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report if:

- No suitable generator is in nixpkgs and path A would require a new flake input — default to path B and report; don't add a flake input without operator sign-off.
- `Colors.qml`'s `load()` contract has drifted from what this plan describes (re-read `Colors.qml` first; the contract in Step 2 must match the live code).
- The generator's output format can't be adapted to the `Colors.qml` shape with a short `jq` filter — report; path A may be infeasible.
- A wallpaper-picker or auto-regen feature seems required for a useful spike — resist; the spike is manual-run only. Report the temptation as an open question.

## Maintenance notes

- The `Colors.qml` `Palette` property list is the source of truth for valid keys; if roles are added/removed there, this README's contract section must update.
- If a future plan auto-regenerates on wallpaper change (systemd path unit), the manual `nesw-recolor` script from path A becomes the unit's ExecStart — design it to stay idempotent.
- Reviewer: confirm the example JSON actually parses and applies (trace `load()`: `colors = scheme.colors`, keys map to `m3<name>` props that exist on `Palette`).
- Open question for the maintainer: should the rebuild-time `nesw.theme.colors` and the live `scheme.json` share a single source (e.g. generate both from one palette file)? That's a larger refactor; out of scope here.
