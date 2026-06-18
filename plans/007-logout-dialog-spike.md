# Plan 007: Build the Quickshell session/logout dialog and bind `kbSession`

> **Executor instructions**: This is a **design + spike plan**, not a build-everything plan. The goal is to define the API, prototype the smallest working dialog, bind the key, and list open questions — then stop. Follow each step; run verification gates. If anything in the "STOP conditions" occurs, stop and report. When done, update the status row in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 17b661a..HEAD -- modules/desktop/quickshell/config/shell.qml modules/desktop/hyprland/config/keybinds.lua modules/desktop/hyprland/default.nix modules/desktop/hyprland/config/rules.lua`
> If these changed, re-read them before proceeding.

## Status

- **Priority**: P3
- **Effort**: M
- **Risk**: MED
- **Depends on**: none (plan 002 updates the `kbSession` doc row to point here; that's doc-only and independent)
- **Category**: direction
- **Planned at**: commit `17b661a`, 2026-06-17
- **Issue**: (not published)

## Why this matters

Half-built intent: `modules/desktop/hyprland/config/rules.lua` has a layer rule for the `logout_dialog` namespace (`animation = "fade"`), and `variables.lua` defines `kbSession = "CTRL + ALT + Delete"` — but no dialog UI exists and the key is never bound. `KEYBINDINGS.md` hedges "bind if used." Closing this loop delivers a real session menu (logout/reboot/shutdown/suspend) that matches the rest of the Quickshell UI, and activates an option that's currently dead. This plan designs the smallest viable version and prototypes it; a follow-up can polish.

## Current state

- `modules/desktop/hyprland/default.nix` — `variablesLua` defines `kbSession = "CTRL + ALT + Delete"` (line ~113). Generated into `~/.config/hypr/variables.lua`.
- `modules/desktop/hyprland/config/keybinds.lua` — no `kbSession` bind exists (confirmed: `grep -n "kbSession" keybinds.lua` returns nothing).
- `modules/desktop/hyprland/config/rules.lua` — `hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })`.
- `modules/desktop/quickshell/config/shell.qml` — entry point listing each surface:
  ```qml
  ShellRoot {
      TopBar {}
      Border {}
      Notch {}
      Clock {}
      Launcher {}
  }
  ```
- Existing surface exemplars: `Launcher.qml` (a full-screen `PanelWindow` overlay with `WlrLayer.Overlay`, IPC toggle, open/close animations, keyboard focus) is the closest pattern to follow. `Notch.qml` shows `PanelWindow` + `Quickshell.Hyprland` dispatch. `Constants.qml` and `Colors.qml`/`Fonts.qml` provide shared styling.
- Hyprland dispatch for session actions: `vars.suspendCommand = "systemctl suspend"` is already used by the suspend keybind (`SUPER + SHIFT + L`) and the three-finger-down gesture. Reboot/shutdown/logout use `systemctl reboot`, `systemctl poweroff`, and `loginctl terminate-user ""` (or `hyprctl dispatch exit`).
- `Quickshell.Hyprland` is already imported in `Notch.qml`; `Hyprland.dispatch(...)` is the dispatch path used elsewhere (e.g. `Notch.qml goToWorkspace`).

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Build | `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` | exit 0 |
| Lua style | `stylua --check modules/desktop/hyprland/config/keybinds.lua` | exit 0 |
| Dialog registered | `grep -n "Logout {}" modules/desktop/quickshell/config/shell.qml` | one match |
| Key bound | `grep -n "kbSession" modules/desktop/hyprland/config/keybinds.lua` | one match |

## Scope

**In scope** (spike):
- `modules/desktop/quickshell/config/Logout.qml` (create)
- `modules/desktop/quickshell/config/shell.qml` (add `Logout {}`)
- `modules/desktop/hyprland/config/keybinds.lua` (bind `kbSession`)

**Out of scope** (defer — list in open questions, don't build):
- Confirmation prompts, icons, animations beyond the existing `fade` layer rule.
- Replacing `wlogout` or any external tool.
- Theming the dialog beyond `Colors.palette` + `Fonts` already in use.
- Changing `kbSession`'s default key.

## Git workflow

- Branch: `advisor/007-logout-dialog-spike`
- Commit: `spike: quickshell logout dialog + kbSession bind`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Define the API (design — no code yet)

Write the design as a comment block at the top of the new `Logout.qml`. Decide and record:

- **Surface**: a `PanelWindow` overlay on `Quickshell.screens[0]`, anchored all sides, `WlrLayer.Overlay`, `WlrLayershell.namespace: "logout_dialog"` (matches the existing layer rule), transparent background, click-outside-to-dismiss (mirror `Launcher.qml`'s `MouseArea` + `hitMask`).
- **Visibility**: a `property bool open: false`, toggled by an `IpcHandler { target: "logout" }` with `toggle`/`show`/`hide` (mirror `Launcher.qml`'s `IpcHandler`). Keyboard focus when open, like `Launcher.qml` (`WlrKeyboardFocus.Exclusive` when open).
- **Actions**: four buttons — Logout, Suspend, Reboot, Shutdown. Each calls `Hyprland.dispatch(...)` or `Quickshell.execDetached(["systemctl", "..."])` / `loginctl`. Suspend reuses `vars.suspendCommand` semantics (but the dialog is QML; it can call `Quickshell.execDetached(["systemctl", "suspend"])` directly, matching the keybind's `vars.suspendCommand` value). Logout: `Quickshell.execDetached(["hyprctl", "dispatch", "exit"])` or `loginctl terminate-user ""` — pick one and record why.
- **Styling**: black card like `Launcher.qml` (`panelBg: "#f0000000"`), `Colors.palette` text, `Fonts.family`. A centered vertical `Column` of four `Row`/`Rectangle` buttons.
- **Escape**: `Keys.onPressed` Escape → `open = false` (mirror Launcher).

Record any open questions inline (see Step 5).

### Step 2: Create `Logout.qml` (minimal prototype)

Implement the smallest working version per Step 1. Use `Launcher.qml` as the structural template (PanelWindow overlay, IpcHandler, open/close, keyboard focus, click-outside dismiss). Keep it under ~120 lines. No icons, no animations beyond the existing `fade` layer rule.

Key references the executor must consult while writing:
- `modules/desktop/quickshell/config/Launcher.qml` — overlay `PanelWindow`, `IpcHandler`, `hitMask`/`mask`, `WlrKeyboardFocus`, open/close.
- `modules/desktop/quickshell/config/Notch.qml` — `import Quickshell.Hyprland` and `Hyprland.dispatch`.
- `modules/desktop/quickshell/config/Colors.qml`, `Fonts.qml` (generated), `Constants.qml` — styling.
- `modules/desktop/hyprland/config/keybinds.lua` — how `vars.kb*` binds call dispatch/exec (e.g. `vars.kbLauncher` → `hl.dsp.exec_cmd("qs ipc call launcher toggle")`).

The dialog toggles over IPC, exactly like the launcher: `qs ipc call logout toggle`.

**Verify**: `test -f modules/desktop/quickshell/config/Logout.qml && echo ok` → `ok`.

### Step 3: Register the surface in `shell.qml`

Add `Logout {}` to the `ShellRoot` (order doesn't matter; put it last so it overlays):

```qml
ShellRoot {
    TopBar {}
    Border {}
    Notch {}
    Clock {}
    Launcher {}
    Logout {}
}
```

**Verify**: `grep -n "Logout {}" modules/desktop/quickshell/config/shell.qml` → one match.

### Step 4: Bind `kbSession` in `keybinds.lua`

Add the bind near the other app binds (around `vars.kbLauncher`), mirroring the launcher's IPC toggle:

```lua
hl.bind(vars.kbSession, hl.dsp.exec_cmd("qs ipc call logout toggle"), { locked = true })
```

(`{ locked = true }` so the key works even when a lock screen is active — session management should always be reachable. Confirm this matches Hyprland 0.55+ `hl.bind` option shape by comparing to the existing `{ locked = true }` binds on the volume keys.)

**Verify**: `grep -n "kbSession" modules/desktop/hyprland/config/keybinds.lua` → one match.
**Verify**: `stylua --check modules/desktop/hyprland/config/keybinds.lua` → exit 0.

### Step 5: Build and record open questions

**Verify**: `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` → exit 0.

Then append an "Open questions" section to the top-of-file design comment in `Logout.qml` (these are for the maintainer, not things to resolve in this spike):

- Should the dialog confirm destructive actions (shutdown/reboot) with a second tap? (Deferred — one-tap for the spike.)
- Should suspend be a button, or is the dedicated `SUPER+SHIFT+L` keybind enough? (Keep for now; remove if redundant.)
- Logout via `hyprctl dispatch exit` vs `loginctl terminate-user ""` — which survives a Hyprland crash better? (Picked one for the spike; revisit.)
- Should the dialog auto-dismiss after an action, or stay open until the session actually ends? (Auto-close on action for the spike.)

## Test plan

No QML unit tests. Verification:
- Build passes.
- `Logout.qml` exists, `shell.qml` registers it, `keybinds.lua` binds `kbSession`.
- Manual runtime check (operator): `qs ipc call logout toggle` opens/closes the dialog; each button performs its action; Escape and click-outside dismiss; `CTRL+ALT+Delete` toggles it.
- Cross-check: the `logout_dialog` namespace layer rule in `rules.lua` now has a matching surface.

## Done criteria

- [ ] `modules/desktop/quickshell/config/Logout.qml` exists with a design-comment header + open-questions section
- [ ] `grep -n "Logout {}" modules/desktop/quickshell/config/shell.qml` → one match
- [ ] `grep -n "kbSession" modules/desktop/hyprland/config/keybinds.lua` → one match
- [ ] `stylua --check modules/desktop/hyprland/config/keybinds.lua` exits 0
- [ ] `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` exits 0
- [ ] Only the three in-scope files are modified
- [ ] `plans/README.md` status row updated (mark IN PROGRESS or DONE per operator)

## STOP conditions

Stop and report if:

- `Quickshell.Hyprland` dispatch or `Quickshell.execDetached` can't run session commands from QML (permission/sandboxing) — report; the dialog may need to shell out to `systemctl` via a different path.
- `qs ipc call` doesn't support a `logout` target the way it supports `launcher` — report; the toggle mechanism needs rework.
- The `hl.bind` option shape (`{ locked = true }`) has changed in the installed Hyprland — match the existing volume-key binds exactly; if none use `locked`, drop it.
- A `Logout.qml` already exists (it shouldn't at `17b661a`).
- Building the dialog well requires changes to `rules.lua` or `variables.lua` beyond adding the bind — report; don't silently expand scope.

## Maintenance notes

- After this lands, plan 002's `kbSession` doc row should be updated from "defined but not bound" to the real binding — note that follow-up.
- The `logout_dialog` layer rule in `rules.lua` is now load-bearing; don't delete it in future cleanup.
- If a real confirmation step is added later, the spike's one-tap behavior changes — flag in review.
- Reviewer: confirm the four session actions use safe, non-interpolated command args (no shell string built from untrusted input); prefer `execDetached(["systemctl", "poweroff"])` array form over `sh -c`.
