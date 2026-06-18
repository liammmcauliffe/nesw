# Plan 009: Generalize the Fish rebuild helpers for multi-host

> **Executor instructions**: Follow this plan step by step. Run every verification command and confirm the expected result before moving to the next step. If anything in the "STOP conditions" occurs, stop and report — do not improvise. When done, update the status row in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 17b661a..HEAD -- modules/shell/fish/functions/ hosts/laptop/default.nix flake.nix`
> If these changed, re-read them before proceeding.

## Status

- **Priority**: P3
- **Effort**: M
- **Risk**: MED
- **Depends on**: none (interacts with plan 006's hostname assertion — read it, but no hard dependency)
- **Category**: tech-debt
- **Planned at**: commit `17b661a`, 2026-06-17
- **Issue**: (not published)

## Why this matters

The README advertises a "flake-based multi-host layout … ready to add more machines," but the Fish rebuild helpers hardcode two single-host assumptions: the flake target `.#main` and the clone path `~/nesw` (via `_nesw_repo`). Adding a second host today means the helpers rebuild the wrong machine. This plan makes the host and repo path derivable rather than hardcoded, so the advertised multi-host path actually works — while keeping the single-host case zero-config.

## Current state

`modules/shell/fish/functions/_nesw_repo.fish`:

```fish
function _nesw_repo --description "Enter ~/nesw or fail"
    if not test -d ~/nesw
        echo "✗ ~/nesw not found"
        return 1
    end
    pushd ~/nesw
end
```

`modules/shell/fish/functions/nswitch.fish` (and `ntest`, `nupdate` are structurally identical — all call `_nesw_repo`, then `sudo nixos-rebuild {switch,test} --flake .#main $argv`):

```fish
function nswitch --description "Stage all, rebuild and switch to new config"
    _nesw_repo || return 1
    _nesw_stage || begin; popd; return 1; end
    set -l t0 (date +%s)
    echo "→ rebuilding..."
    if sudo nixos-rebuild switch --flake .#main $argv
        echo "✓ done in "(math (date +%s) - $t0)"s"
        popd
    else
        echo "✗ rebuild failed"
        popd
        return 1
    end
end
```

`ntest.fish`: `sudo nixos-rebuild test --flake .#main $argv`.
`nupdate.fish`: `nix flake update --flake .` then `sudo nixos-rebuild test --flake .#main`.
`nrollback.fish`: `sudo nixos-rebuild switch --rollback` (no `.#main`, no repo — unaffected).

`flake.nix` builds `nixosConfigurations.main` (one host). `hosts/laptop/default.nix` is `{ configuration = ./configuration.nix; home = ./home.nix; }`.

Hostname convention: `hosts/laptop/configuration.nix` sets `networking.hostName = "main"`, matching the flake target. So **the hostname is already the flake target name** — the helpers can derive it from `hostname` rather than hardcoding `main`.

Repo path: `~/nesw` is the documented clone location (README §1). `_nesw_repo` could honor a `$NESW_DIR` override (falling back to `~/nesw`) — but note `modules/desktop/hyprland/README.md`'s stale `NESW_DIR` claim is being removed by plan 002; introducing a *real* `NESW_DIR` for the fish helpers is a different, legitimate use (shell var, not Hyprland env). Decide in Step 1 whether to add it.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Fish syntax check | `fish --no-config -c 'source modules/shell/fish/functions/nswitch.fish; functions nswitch'` (per file) | function prints without error |
| Build | `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` | exit 0 |
| No hardcoded `.#main` | `grep -rn '\.#{1,}main' modules/shell/fish/functions/` | no matches |

## Scope

**In scope**:
- `modules/shell/fish/functions/_nesw_repo.fish`
- `modules/shell/fish/functions/nswitch.fish`
- `modules/shell/fish/functions/ntest.fish`
- `modules/shell/fish/functions/nupdate.fish`
- (optionally) `modules/shell/fish/default.nix` — only if a config var needs injecting

**Out of scope**:
- `nrollback.fish` — doesn't reference `.#main` or the repo; leave it.
- `_nesw_stage.fish` — staging logic; only touched if the staged-files list needs to become host-aware (it currently lists `hosts/laptop/*` paths — see open question).
- `flake.nix` / `hosts/` — do not add a second host to test; this plan makes the helpers *ready* for one, it doesn't add one.
- Plan 006's hostname assertion (independent; but the generalized helpers should agree with it).

## Git workflow

- Branch: `advisor/009-multihost-rebuild-helpers`
- Commit: `generalize rebuild helpers for multi-host`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Decide the derivation strategy (design — no code yet)

Record the decision in a comment at the top of `_nesw_repo.fish`. Recommended approach (simplest that works, fewest moving parts):

- **Flake target**: derive from `hostname` — `set -l host (hostnamectl hostname 2>/dev/null; or hostname)`. The flake target is `.#$host`. This matches the existing convention (`hostName = "main"` ↔ `nixosConfigurations.main`) and requires zero per-host config. (If `hostname` is unreliable in some environment, fall back to reading `/etc/hostname`.)
- **Repo path**: honor `NESW_DIR` env var if set, else `~/nesw`. This is a *shell* env var for the fish helpers only — distinct from the stale Hyprland `NESW_DIR` concept removed in plan 002. Keeping the override lets users clone elsewhere; the default keeps single-host zero-config.

Escape hatch: if deriving from `hostname` feels fragile to the operator, the fallback is a per-host `~/.config/nesw/host` file. Prefer `hostname` first; only add the file if Step 4 verification fails.

**Verify**: decision recorded in a comment; no code yet.

### Step 2: Generalize `_nesw_repo.fish`

Replace the body so it resolves the repo dir from `$NESW_DIR` or `~/nesw`, and exports the derived host name for the calling function. Minimal rewrite:

```fish
function _nesw_repo --description "Enter the nesw repo (NESW_DIR or ~/nesw) and fail fast; sets NESW_HOST to the hostname"
    set -l repo "$NESW_DIR"
    if test -z "$repo"
        set repo ~/nesw
    end
    if not test -d "$repo"
        echo "✗ nesw repo not found (set \$NESW_DIR or clone at ~/nesw)"
        return 1
    end
    pushd "$repo"
    # flake target matches networking.hostName (see hosts/<host>/configuration.nix)
    set -gx NESW_HOST (hostnamectl hostname 2>/dev/null; or string trim (cat /etc/hostname 2>/dev/null))
    if test -z "$NESW_HOST"
        echo "✗ could not determine hostname for flake target"
        popd
        return 1
    end
end
```

Note: `set -gx` (global + export) inside a function sets it for the current shell session; since `_nesw_repo` runs in the same shell as `nswitch`/`ntest`/`nupdate` (they're sourced functions, not subshells), the var is visible to the caller. Confirm this with the Step 4 verification.

**Verify**: `fish --no-config -c 'source modules/shell/fish/functions/_nesw_repo.fish; functions _nesw_repo'` → prints the function without error.

### Step 3: Replace `.#main` with `.#$NESW_HOST` in the three helpers

In `nswitch.fish`, `ntest.fish`, `nupdate.fish`, replace every `--flake .#main` with `--flake .#$NESW_HOST`. Example for `nswitch.fish`:

```fish
    if sudo nixos-rebuild switch --flake .#$NESW_HOST $argv
```

(`nupdate.fish` has the `nix flake update --flake .` line — that's path-based, not target-based; leave it as `--flake .`.)

Keep the rest of each function (timing, error messages, `popd`) unchanged.

**Verify**: `grep -rn '\.#[Mm]ain' modules/shell/fish/functions/` → no matches. `grep -rn 'NESW_HOST' modules/shell/fish/functions/` → matches in all three helpers + `_nesw_repo`.

### Step 4: Verify the single-host case still works (no second host needed)

Since the repo only has `.#main` and the machine hostname is `main`, `.#$NESW_HOST` resolves to `.#main` — identical behavior. Confirm:

```
fish --no-config -c '
  set -gx NESW_DIR (pwd)
  source modules/shell/fish/functions/_nesw_repo.fish
  _nesw_repo
  echo "host=($NESW_HOST) flake target=(.#$NESW_HOST)"
  popd
'
```

Expected: `host=(main) flake target=(.#main)` (or the local hostname if run on the dev machine — the point is `NESW_HOST` is non-empty and `.#$NESW_HOST` is well-formed).

(Don't actually run `nixos-rebuild` from this verification — it's a NixOS-only command and the dev machine is macOS. The structural check + build below is sufficient.)

**Verify**: `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` → exit 0 (the helpers don't affect the build, but confirms nothing else broke).

## Test plan

No fish test harness. Verification:
- Each modified function sources without syntax error (`fish --no-config -c 'source ...; functions <name>'`).
- `grep` confirms no `.#main` literal remains in the helpers.
- Single-host case is unchanged in behavior (`.#$NESW_HOST` == `.#main` on the `main` host).
- Manual runtime check (operator, on the NixOS machine): `nswitch`/`ntest`/`nupdate` still rebuild `.#main` correctly; `NESW_DIR=/somewhere/else nswitch` uses the alt path.

## Done criteria

- [ ] `_nesw_repo.fish` resolves repo from `$NESW_DIR` or `~/nesw` and sets `NESW_HOST`
- [ ] `nswitch.fish`, `ntest.fish`, `nupdate.fish` use `.#$NESW_HOST` (no `.#main` literal)
- [ ] `nrollback.fish` is unchanged
- [ ] `grep -rn '\.#[Mm]ain' modules/shell/fish/functions/` returns nothing
- [ ] Each modified function sources without error under `fish --no-config -c`
- [ ] `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` exits 0
- [ ] Only in-scope files modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report if:

- `hostnamectl`/`hostname`/`/etc/hostname` are all unavailable or inconsistent on the target NixOS machine — the derivation strategy needs rework (consider the per-host `~/.config/nesw/host` file fallback).
- `set -gx` inside `_nesw_repo` does **not** make `NESW_HOST` visible to the calling `nswitch`/`ntest`/`nupdate` function (fish scoping surprise) — switch to echoing the host and capturing via `set -l host (_nesw_repo_and_host)` or return the host via a global with a different mechanism; report the chosen approach.
- The dev machine can't run `fish` to syntax-check (unlikely; fish is common) — fall back to careful manual review and note it.
- `_nesw_stage.fish`'s hardcoded `hosts/laptop/*` file list turns out to break multi-host staging — that's a real follow-up but **out of scope** for this plan; report it as an open question, don't fix here.

## Maintenance notes

- `_nesw_stage.fish` still hardcodes `hosts/laptop/...` paths to force-stage. When a second host lands, that function must become host-aware (e.g. stage `hosts/$NESW_HOST/*`). Flag this in review — it's the next thing to break.
- If plan 006's hostname assertion is later generalized to compare against the *actual* flake target name (not hardcoded `"main"`), it should read the same `NESW_HOST` derivation — keep the two consistent.
- The `NESW_DIR` shell var introduced here is unrelated to the stale Hyprland `NESW_DIR` removed in plan 002; don't confuse them. This one is real and lives only in the fish helpers.
- Reviewer: confirm the single-host behavior is byte-for-byte equivalent (the `.#$NESW_HOST` expansion must equal `.#main` on the `main` host), and that `nrollback` wasn't touched.
