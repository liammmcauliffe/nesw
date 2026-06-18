# Plan 002: Correct stale/wrong Hyprland documentation

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 17b661a..HEAD -- KEYBINDINGS.md README.md modules/README.md modules/desktop/hyprland/README.md`
> If any in-scope file changed since this plan was written, compare the "Current state" excerpts against the live code before proceeding.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none (independent of plan 001, but read it — 001 fixes the bind this doc references)
- **Category**: docs
- **Planned at**: commit `17b661a`, 2026-06-17
- **Issue**: (not published)

## Why this matters

The Hyprland docs currently tell readers things that are false: a resize section full of keybindings that don't exist, a `NESW_DIR` environment variable that isn't set anywhere, claims that the Lua tree is symlinked when it's actually copied at build time, wrong file paths (`modules/hyprland/...` instead of `modules/desktop/hyprland/...`), and a `kbSession` key documented as "bind if used" that is never bound. Anyone extending the shell — human or agent — builds a wrong mental model and wastes time. This plan corrects all of them with minimal, accurate rewrites.

## Current state

Four files are in scope. Each issue below is independent; fix them in the order listed.

### File A: `KEYBINDINGS.md`

**A1 — Wrong paths (line 3):**

```
All modifier prefixes live in `modules/hyprland/variables.lua`. Bindings are registered in `modules/hyprland/config/keybinds.lua`. Change a prefix in `variables.lua` to remap a whole group at once.
```

Reality: `variables.lua` is **generated at build time** from `modules/desktop/hyprland/default.nix` (the `variablesLua` attr). Bindings live at `modules/desktop/hyprland/config/keybinds.lua`. The generated file lands at `~/.config/hypr/variables.lua`.

**A2 — "Window resize" section (the table under `## Window resize`) lists non-existent binds:**

```
| Binding | Action |
|---------|--------|
| `SUPER + Equal` | Grow window width (repeat) |
| `SUPER + SHIFT + Minus` | Shrink window height (repeat) |
| `SUPER + SHIFT + Equal` | Grow window height (repeat) |
| `SUPER + ALT + left/right/up/down` | Resize window (repeat) |
```

Reality (from `modules/desktop/hyprland/config/keybinds.lua`): the only resize binds are `SUPER + ALT + left/right/up/down` (relative resize, repeating). `SUPER + Equal` and `SUPER + SHIFT + Equal` do not exist. `SUPER + SHIFT + Minus` does not exist (`SUPER + Minus` exists but is "Jump workspace +10", listed correctly elsewhere). The first three rows must be deleted.

**A3 — `kbSession` in the "System" section:**

```
| `CTRL + ALT + Delete` | Session menu (defined in `variables.lua`, bind if used) |
```

Reality: `kbSession = "CTRL + ALT + Delete"` is defined in `modules/desktop/hyprland/default.nix:113` but **never bound** in `keybinds.lua`, and no session/logout dialog UI ships. The current honest status is "defined but not wired up." Rewrite the row to say so, OR remove the row. Recommended: rewrite to reflect reality and link plan 007 (logout dialog) — but do NOT invent a binding. Suggested row:

```
| `CTRL + ALT + Delete` | Session menu — option `kbSession` is defined in `variables.lua` but not currently bound (see `modules/desktop/hyprland/default.nix`); no logout dialog ships yet. |
```

### File B: `README.md`

**B1 — "Hyprland Lua architecture" table is accurate** (paths are `modules/desktop/hyprland/...`). No change needed there. Confirm only.

No other wrong path references exist in `README.md` (verified: `grep -n "modules/hyprland" README.md` returns nothing).

### File C: `modules/README.md`

**C1 — Line 9 claims symlinking:**

```
**`desktop/`** is the Wayland shell layer. `hyprland/` symlinks a Lua config tree and **generates** `variables.lua` and `scheme/*.lua` from Nix options ...
```

**C2 — Line 22 claims symlinking:**

```
The rest of `config/*.lua` is symlinked from the repo. Edit those files for keybinds, rules, and gestures.
```

Reality: `modules/desktop/hyprland/default.nix` builds `hyprConfig` via `pkgs.runCommand` that does `cp -ra ${hyprSrc}/. $out/` then writes the generated `variables.lua` / `scheme/*.lua` on top. It is a **copy**, deployed through `xdg.configFile.hypr` with `recursive = true`. Edits to repo `config/*.lua` take effect on the next rebuild, not via live symlink.

Replace "symlinks a Lua config tree" → "copies a Lua config tree into the build output". Replace "is symlinked from the repo" → "is copied from the repo at build time; rebuild to pick up edits".

### File D: `modules/desktop/hyprland/README.md`

**D1 — Line 3 claims symlinking:**

```
Hyprland compositor configuration for nesw. Lua sources live in this directory and are symlinked to `~/.config/hypr` for rapid iteration.
```

Replace "are symlinked to `~/.config/hypr` for rapid iteration" → "are copied to `~/.config/hypr` at build time (rebuild to pick up edits)".

**D2 — The `## NESW_DIR` section is entirely stale.** Current text:

```
## `NESW_DIR`

Lua configs resolve the repo via `NESW_DIR` (defaults to `~/nesw`). Set it in `config/env.lua` or your environment if the clone lives elsewhere.
```

Reality: `config/env.lua` sets no `NESW_DIR` variable. `hyprland.lua` (the entry point) header comment says:

```
--[[
  Hyprland entry point (0.55+ loads ~/.config/hypr/hyprland.lua directly).
  require() resolves under ~/.config/hypr/ - no repo path or NESW_DIR needed.
]]
```

`require("config.env")`, `require("variables")`, etc. resolve under `~/.config/hypr/` because that is where the copy + generated files live. **Delete the entire `## NESW_DIR` section.**

**D3 — Lua-layout table row for `config/decoration.lua`:**

```
| `config/decoration.lua` | Blur and shadow |
```

Reality: the shadow block was removed; `config/decoration.lua` now configures blur only. Change "Blur and shadow" → "Blur".

**D4 — Lua-layout table row for `config/env.lua`:**

```
| `config/env.lua` | Environment variables (`NESW_DIR`) |
```

Reality: no `NESW_DIR`. Change to "Environment variables (Wayland/XDG/Qt)" — `config/env.lua` sets `QT_QPA_PLATFORMTHEME`, `XCURSOR_*`, `GDK_BACKEND`, `XDG_*`, etc.

**D5 — "Override apps and colors in `hosts/laptop/local.nix`" code block (line ~14):** The example itself is fine, but note `local.nix` is NixOS-side (drivers, system). Theme/hyprland app overrides canonically go in `shared.nix` (imported by both NixOS and Home Manager). Change the sentence above the example from "Override apps and colors in `hosts/laptop/local.nix`:" to "Override apps and colors in `hosts/laptop/shared.nix` (imported by both NixOS and Home Manager):". This matches `README.md`'s "Where to edit what" table, which already says `shared.nix`.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Confirm no stale tokens remain | `grep -rn "NESW_DIR\|modules/hyprland/\|symlinked to \`~/\.config/hypr\|symlinks a Lua\|is symlinked from" KEYBINDINGS.md README.md modules/README.md modules/desktop/hyprland/README.md` | no matches |
| Confirm dead resize binds gone from docs | `grep -n "SUPER + Equal\|SUPER + SHIFT + Minus\|SUPER + SHIFT + Equal" KEYBINDINGS.md` | no matches |
| Build still passes (docs don't affect build, but sanity) | `nix flake check` | exit 0 |

## Scope

**In scope**:
- `KEYBINDINGS.md`
- `modules/README.md`
- `modules/desktop/hyprland/README.md`

**Out of scope**:
- `README.md` — already accurate (paths correct; no symlink/NESW_DIR claims). Only touch if a grep reveals drift.
- Any `.nix` or `.lua` source.
- Plan 001's bind fix (separate plan).
- Plan 007's logout dialog (do not add a binding here).

## Git workflow

- Branch: `advisor/002-fix-hyprland-docs`
- Commit: e.g. `fix stale hyprland docs`. One commit for all four files is fine.
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: `KEYBINDINGS.md`

1. Fix line 3 paths: `modules/hyprland/variables.lua` → note it is generated; `modules/hyprland/config/keybinds.lua` → `modules/desktop/hyprland/config/keybinds.lua`. Suggested rewrite of line 3:
   ```
   All modifier prefixes live in `~/.config/hypr/variables.lua`, generated from `modules/desktop/hyprland/default.nix` at build time. Bindings are registered in `modules/desktop/hyprland/config/keybinds.lua`. Change a prefix in the `variablesLua` attr of `default.nix` to remap a whole group at once.
   ```
2. Delete the three non-existent rows from the `## Window resize` table, leaving only `SUPER + ALT + left/right/up/down`.
3. Rewrite the `CTRL + ALT + Delete` row per A3 above to reflect "defined but not bound."

**Verify**: `grep -n "modules/hyprland/" KEYBINDINGS.md` → no matches. `grep -n "SUPER + Equal\|SUPER + SHIFT + Equal\|SUPER + SHIFT + Minus" KEYBINDINGS.md` → no matches.

### Step 2: `modules/README.md`

1. Line 9: "symlinks a Lua config tree" → "copies a Lua config tree into the build output".
2. Line 22: "is symlinked from the repo. Edit those files for keybinds, rules, and gestures." → "is copied from the repo at build time. Edit those files for keybinds, rules, and gestures, then rebuild (`ntest`/`nswitch`) to pick up the changes."

**Verify**: `grep -n "symlink" modules/README.md` → no matches.

### Step 3: `modules/desktop/hyprland/README.md`

1. Line 3: replace "are symlinked to `~/.config/hypr` for rapid iteration" → "are copied to `~/.config/hypr` at build time (rebuild to pick up edits)".
2. Delete the entire `## NESW_DIR` section and its code/text.
3. Lua-layout table: `config/decoration.lua` row "Blur and shadow" → "Blur".
4. Lua-layout table: `config/env.lua` row "Environment variables (`NESW_DIR`)" → "Environment variables (Wayland/XDG/Qt)".
5. The "Override apps and colors" sentence: `hosts/laptop/local.nix` → `hosts/laptop/shared.nix` and add "(imported by both NixOS and Home Manager)".

**Verify**: `grep -n "NESW_DIR\|symlink" modules/desktop/hyprland/README.md` → no matches. `grep -n "Blur and shadow" modules/desktop/hyprland/README.md` → no matches.

### Step 4: Final cross-check

**Verify**: `grep -rn "NESW_DIR\|modules/hyprland/" KEYBINDINGS.md modules/README.md modules/desktop/hyprland/README.md` → no matches.

**Verify**: `grep -rn "symlink" KEYBINDINGS.md modules/README.md modules/desktop/hyprland/README.md` → no matches.

## Test plan

Docs-only; no automated tests. Verification is the grep gates above. A human read-through of the four files should show: no path that doesn't resolve in the repo, no bind documented that isn't in `keybinds.lua`, no `NESW_DIR` mention, no "symlink" claim.

Cross-reference for any remaining documented bind: every binding row in `KEYBINDINGS.md` should correspond to either a `hl.bind(...)` line in `modules/desktop/hyprland/config/keybinds.lua` or a `kb*` var in `modules/desktop/hyprland/default.nix`. The `kbSession` row is the documented exception (defined, not bound).

## Done criteria

- [ ] `grep -rn "NESW_DIR" KEYBINDINGS.md modules/README.md modules/desktop/hyprland/README.md` returns nothing
- [ ] `grep -rn "modules/hyprland/" KEYBINDINGS.md modules/README.md modules/desktop/hyprland/README.md` returns nothing
- [ ] `grep -rn "symlink" KEYBINDINGS.md modules/README.md modules/desktop/hyprland/README.md` returns nothing
- [ ] `grep -n "SUPER + Equal\|SUPER + SHIFT + Equal\|SUPER + SHIFT + Minus" KEYBINDINGS.md` returns nothing
- [ ] `grep -n "Blur and shadow" modules/desktop/hyprland/README.md` returns nothing
- [ ] The `## Window resize` table in `KEYBINDINGS.md` has exactly one row (`SUPER + ALT + left/right/up/down`)
- [ ] `nix flake check` exits 0
- [ ] No files outside the in-scope list are modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report if:

- Any in-scope file's "Current state" excerpt doesn't match the live file (drift since `17b661a`).
- You find a documented binding that is neither in `keybinds.lua` nor a `kb*` var in `default.nix` and isn't `kbSession` — report it rather than silently deleting; it may be a real missing bind (separate from 001).
- `modules/desktop/hyprland/default.nix` no longer generates `variables.lua` via a `variablesLua`-like attr (the build mechanism changed) — the line-3 rewrite assumes generation.

## Maintenance notes

- After plan 007 (logout dialog) lands, revisit the `kbSession` row: it should then document the real binding.
- The "copy not symlink" wording must stay accurate; if a future change switches to `xdg.configFile` symlink mode, update both READMEs again.
- Reviewer: spot-check 3–4 documented binds against `keybinds.lua` to confirm the table now reflects reality.
