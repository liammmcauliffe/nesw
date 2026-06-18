# Plan 005: Harden Launcher history persistence against shell injection

> **Executor instructions**: Follow this plan step by step. Run every verification
> command and confirm the expected result before moving to the next step. If
> anything in the "STOP conditions" section occurs, stop and report — do not
> improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 17b661a..HEAD -- modules/desktop/quickshell/config/Launcher.qml`
> If this file changed, compare the "Current state" excerpts against the live code before proceeding.

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: security
- **Planned at**: commit `17b661a`, 2026-06-17
- **Issue**: (not published)

## Why this matters

`Launcher.qml` persists launch-frequency history to `~/.local/state/nesw/launcher-history.json` by shelling out to `sh -c` with the JSON interpolated into a single-quoted argument, escaped with a hand-rolled `replace(/'/g, "'\\''")`. The history object is keyed by desktop-entry `id`/`name` — content read from `.desktop` files installed on the system, i.e. untrusted input. The current single-quote escaping is the standard idiom and is *probably* safe, but it's a brittle injection surface sitting next to untrusted data: one regression in the escaping and a malicious `.desktop` file's name becomes shell execution. Replacing the shell-out with Quickshell's file-writing API removes the interpreter from the data path entirely.

## Current state

File: `modules/desktop/quickshell/config/Launcher.qml`. The history persistence path (lines ~79–96):

```js
    function persistHistory() {
        const json = JSON.stringify(launchHistory);
        const dir = `${Quickshell.env("HOME")}/.local/state/nesw`;
        const path = root.historyPath;
        Quickshell.execDetached({
            command: [
                "sh", "-c",
                `mkdir -p '${dir}' && printf '%s' '${json.replace(/'/g, "'\\''")}' > '${path}'`
            ],
        });
    }
```

- `launchHistory` is `{ [key]: <Date.now() number> }`, where `key = entry.id || entry.name` (see `historyKey`).
- `historyPath` = `` `${Quickshell.env("HOME")}/.local/state/nesw/launcher-history.json` `` (readonly property near the top of the `PanelWindow`).
- `saveHistory(entry)` calls `persistHistory()` after updating `launchHistory`.
- Read path uses `FileView { path: root.historyPath; watchChanges: false; printErrors: false; onLoaded: root.loadHistory(text()) }` — already uses the FileView API, no shell.
- `home.file.".local/state/nesw/.keep".text = ""` in `modules/desktop/quickshell/default.nix` pre-creates the state dir at build time, so `mkdir -p` is only needed as a defensive fallback (the dir already exists on a real install).

Quickshell provides `Quickshell.Io.FileView` (read, already used here) and, for writing, the `FileView` can be used in write mode OR `Quickshell.Io` exposes `writeFile`/`JSON.write`. The exact write API must be confirmed against the installed Quickshell version (see STOP conditions). The cleanest replacement that avoids a shell entirely is a write-mode `FileView` or a direct `Io` write call.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Confirm Quickshell write API | (read Quickshell docs / installed QML dir — see Step 1) | a non-shell write primitive is available |
| Build | `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` | exit 0 |
| No shell-out remains | `grep -n "execDetached\|sh -c\|printf '%s'" modules/desktop/quickshell/config/Launcher.qml` | no matches in `persistHistory` |

## Scope

**In scope**:
- `modules/desktop/quickshell/config/Launcher.qml` (the `persistHistory` function only)

**Out of scope**:
- The read path (`FileView` + `loadHistory`) — already shell-free.
- `saveHistory`, `historyKey`, `loadHistory` — do not change.
- `modules/desktop/quickshell/default.nix` — the `.keep` dir pre-create is fine.
- Any other QML file.

## Git workflow

- Branch: `advisor/005-launcher-history-hardening`
- Commit: `harden launcher history persistence (no shell-out)`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Confirm the available Quickshell write primitive

Before writing code, determine which non-shell write API the pinned Quickshell provides. Check, in order:

1. `grep -rn "function writeFile\|signal writeFile\|property.*writeFile" <quickshell-qml-dir>` where `<quickshell-qml-dir>` is the Quickshell QML sources from the flake input (run `nix build .#quickshell` or inspect the flake input path). 
2. The Quickshell docs at `https://quickshell.outfoxxed.me/docs/` — look for `FileView` write mode or `Io.writeText`/`JSON.write`.
3. If a `FileView` supports a `write(text)` method or a write mode, prefer it (consistent with the existing read `FileView`).

Record which API you used. If **none** exists in this Quickshell version, STOP and report — do not fall back to the shell-out.

**Verify**: you have identified a specific write primitive (name it in your final report).

### Step 2: Rewrite `persistHistory` to use the write primitive

Replace the body of `persistHistory` so it writes `JSON.stringify(launchHistory)` directly to `root.historyPath` without invoking `sh`/`printf`. Keep the function's contract identical: called from `saveHistory`, no return value, no UI side-effects.

Two acceptable shapes depending on Step 1's finding:

**If `FileView` has a write method** (preferred — reuse the existing read FileView by adding a writer, or add a second `FileView` in write mode):

```js
    function persistHistory() {
        const json = JSON.stringify(launchHistory);
        historyWriter.writeText(json);
    }
```

with a corresponding `FileView` (or `FileView`-like) element added near the existing read `FileView`:

```qml
    FileView {
        id: historyWriter
        path: root.historyPath
        printErrors: false
    }
```

(Use the exact method name confirmed in Step 1 — `writeText`, `write`, or the `JSON.write` helper. Do not invent a name.)

**If `Quickshell.Io` exposes a stateless write function**, call it directly:

```js
    function persistHistory() {
        const json = JSON.stringify(launchHistory);
        Io.writeText(root.historyPath, json);   // name per Step 1
    }
```

(Ensure `import Quickshell.Io` is present — it already is, used by the read `FileView`.)

Either way, the `mkdir -p` is no longer needed because `modules/desktop/quickshell/default.nix` pre-creates `~/.local/state/nesw/` via the `.keep` file. (Confirm: `grep -n ".local/state/nesw/.keep" modules/desktop/quickshell/default.nix`.)

**Verify**: `grep -n "execDetached\|sh -c\|printf '%s'" modules/desktop/quickshell/config/Launcher.qml` → no matches.

**Verify**: `grep -n "persistHistory" modules/desktop/quickshell/config/Launcher.qml` → the function still exists and is still called from `saveHistory`.

### Step 3: Build

**Verify**: `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` → exit 0.

(QML isn't separately compiled by `nix flake check`; it's deployed as text. A syntax error would surface only at Quickshell runtime. If a `qs` QML lint/parse command is available locally — `qs -c nesw --check` or similar — run it; otherwise rely on the build + a manual read of the edited function.)

## Test plan

No QML unit tests exist. Verification:
- `grep` confirms no shell-out remains in `persistHistory`.
- The function still serializes `launchHistory` and writes to `root.historyPath`.
- Build passes; the QML deploys.
- Manual runtime check (operator, optional): open the launcher, launch an app, confirm `~/.local/state/nesw/launcher-history.json` is updated with the new timestamp and is valid JSON (`jq . < file`).

## Done criteria

- [ ] `grep -n "execDetached\|sh -c\|printf '%s'" modules/desktop/quickshell/config/Launcher.qml` returns no matches
- [ ] `persistHistory` writes via a Quickshell file API (no shell), name recorded in the report
- [ ] `saveHistory` still calls `persistHistory`
- [ ] `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` exits 0
- [ ] Only `modules/desktop/quickshell/config/Launcher.qml` is modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report if:

- The pinned Quickshell version exposes **no** non-shell file-write primitive (Step 1). Do not keep the shell-out with "better" escaping — report so the plan can be reconsidered (e.g. pin a newer Quickshell, or accept the status quo).
- The `Launcher.qml` "Current state" excerpt doesn't match the live code (drift).
- `modules/desktop/quickshell/default.nix` no longer pre-creates `~/.local/state/nesw/` (no `.keep` file) — then `persistHistory` must also ensure the dir exists; report and extend scope before continuing.
- The confirmed write API has different semantics (e.g. requires the file to pre-exist, or is async-only) that break the overwrite-in-place contract — report.

## Maintenance notes

- The chosen write API name should be added to `AGENTS.md`'s generated-files / Quickshell notes if a future plan refreshes it.
- If `launchHistory` grows to hold large data, the synchronous write could stall the shell thread; revisit with an async write if that happens.
- Reviewer: confirm the new code path contains zero string interpolation into a shell, and that the JSON is written as a literal argument to a file API.
