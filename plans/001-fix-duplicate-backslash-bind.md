# Plan 001: Fix duplicate `CTRL+SUPER+ALT+Backslash` bind that shadows the resize

> **Executor instructions**: Follow this plan step by step. Run every
> verification command and confirm the expected result before moving to the
> next step. If anything in the "STOP conditions" section occurs, stop and
> report — do not improvise. When done, update the status row for this plan
> in `plans/README.md` — unless a reviewer dispatched you and told you they
> maintain the index.
>
> **Drift check (run first)**: `git diff --stat 17b661a..HEAD -- modules/desktop/hyprland/config/keybinds.lua`
> If this file changed since this plan was written, compare the "Current state"
> excerpts against the live code before proceeding; on a mismatch, treat it as
> a STOP condition.

## Status

- **Priority**: P1
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: bug
- **Planned at**: commit `17b661a`, 2026-06-17
- **Issue**: (not published)

## Why this matters

`KEYBINDINGS.md` documents `CTRL + SUPER + ALT + Backslash` as "Picture-in-picture resize + center" — a combo that should resize the active window to 55%×70% of the screen **and** center it. In `keybinds.lua` the same key is bound twice in a row: first to the resize, then to the center. Hyprland's `hl.bind` last-writer-wins, so the resize is silently dropped and the combo only centers. Users following the docs get half the behavior with no error.

## Current state

File: `modules/desktop/hyprland/config/keybinds.lua` — keybinding registration.

Relevant lines (101–104):

```lua
hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.center())
hl.bind("CTRL + SUPER + ALT + Backslash", hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
hl.bind("CTRL + SUPER + ALT + Backslash", hl.dsp.window.center())
hl.bind(vars.kbWindowPip, function()
```

`fn` is `require("config.functions")` (see top of file). `fn.resize_by_screen(55, 70)` returns a resize dispatch arg (or `nil` if the monitor lookup fails — see `modules/desktop/hyprland/config/functions.lua`, `resize_by_screen`). `hl.dispatch(...)` issues a dispatch; the existing `CTRL + SUPER + Backslash` center bind and the `vars.kbWindowPip` function-callback bind show the two patterns used in this file (single dispatch arg vs. function that runs multiple dispatches).

Repo convention for multi-dispatch binds: a function body that calls `hl.dispatch(...)` for each action, in order. Example already in this file — `vars.kbWindowPip`:

```lua
hl.bind(vars.kbWindowPip, function()
    local a = hl.get_active_window()
    if a then
        local pip = fn.move_actions() or {}
        table.insert(pip, hl.dsp.window.pin())
        fn.resizer(a.title, 0, 0, pip, true)
    end
end)
```

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Style check (Lua) | `stylua --check modules/desktop/hyprland/config/keybinds.lua` | exit 0 (file already stylua-compliant; `.stylua.toml` at repo root: column_width=120, spaces, indent 2) |
| Flake check | `nix flake check` | exit 0 |
| Dry-build | `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` | exit 0 |

(No Lua runtime test harness exists; verification is `stylua --check` + the Nix build, which deploys the file.)

## Scope

**In scope**:
- `modules/desktop/hyprland/config/keybinds.lua`

**Out of scope**:
- `modules/desktop/hyprland/config/functions.lua` (do not change `resize_by_screen`).
- `KEYBINDINGS.md` (the doc text is correct once the bind works; doc cleanup is plan 002).
- Any other bind.

## Git workflow

- Branch: `advisor/001-fix-duplicate-backslash-bind`
- Commit style (from `git log --oneline`): short lowercase imperative subjects, e.g. `fix duplicate backslash bind`. One commit is fine.
- Do NOT push or open a PR unless the operator instructed it.

## Steps

### Step 1: Merge the two `CTRL + SUPER + ALT + Backslash` binds into one function

Replace these two lines:

```lua
hl.bind("CTRL + SUPER + ALT + Backslash", hl.dsp.window.resize(fn.resize_by_screen(55, 70)))
hl.bind("CTRL + SUPER + ALT + Backslash", hl.dsp.window.center())
```

with a single bind that dispatches both actions in order (resize first, then center), guarding the resize arg for `nil` the way the rest of the file guards monitor/window lookups:

```lua
hl.bind("CTRL + SUPER + ALT + Backslash", function()
    local size = fn.resize_by_screen(55, 70)
    if size then
        hl.dispatch(hl.dsp.window.resize(size))
    end
    hl.dispatch(hl.dsp.window.center())
end)
```

Keep the surrounding `CTRL + SUPER + Backslash` (center) bind above it and the `vars.kbWindowPip` bind below it unchanged.

**Verify**: `stylua --check modules/desktop/hyprland/config/keybinds.lua` → exit 0.

**Verify**: `grep -n "CTRL + SUPER + ALT + Backslash" modules/desktop/hyprland/config/keybinds.lua` → exactly one matching line.

## Test plan

No unit-test harness exists for the Hyprland Lua config. Verification is structural + build:
- Exactly one bind for the combo (grep above).
- The function dispatches resize (guarded) then center — matches the documented "resize + center" behavior.
- Nix build succeeds (file is deployed by `modules/desktop/hyprland/default.nix` via `cleanSourceWith` + `runCommand`).

## Done criteria

- [ ] `grep -c "CTRL + SUPER + ALT + Backslash" modules/desktop/hyprland/config/keybinds.lua` prints `1`
- [ ] `stylua --check modules/desktop/hyprland/config/keybinds.lua` exits 0
- [ ] `nix flake check` exits 0
- [ ] No files outside `modules/desktop/hyprland/config/keybinds.lua` are modified (`git status`)
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report back (do not improvise) if:

- The code at `keybinds.lua:101-104` doesn't match the "Current state" excerpts (the codebase has drifted).
- `fn.resize_by_screen` does not exist or has a different signature than `resize_by_screen(width_pct, height_pct)` (check `modules/desktop/hyprland/config/functions.lua`).
- `stylua` is not available and no equivalent Lua formatter is installed — report and skip that verification gate rather than skipping the change.

## Maintenance notes

- If a future change makes `resize_by_screen` return a dispatch arg directly (instead of the raw size table), the `hl.dsp.window.resize(size)` wrapping must be revisited.
- The `nil`-guard is deliberate: on a monitor lookup failure, centering alone is better than a resize error. Keep it.
- Reviewer: confirm the combo now resizes then centers, and that `CTRL + SUPER + Backslash` (center-only) is still its own bind above.
