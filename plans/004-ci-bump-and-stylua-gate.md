# Plan 004: Bump CI action and add a formatter gate

> **Executor instructions**: Follow this plan step by step. Run every verification
> command and confirm the expected result before moving to the next step. If
> anything in the "STOP conditions" section occurs, stop and report — do not
> improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 17b661a..HEAD -- .github/workflows/check.yml .stylua.toml flake.nix`
> If these changed, re-read them before editing.

## Status

- **Priority**: P3
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: dx
- **Planned at**: commit `17b661a`, 2026-06-17
- **Issue**: (not published)

## Why this matters

CI pins `cachix/install-nix-action@v25`; the current major is v27, and v25 lags security fixes and newer Nix features. Separately, the repo has a `.stylua.toml` (column 120, 2-space indent) but nothing enforces it — Lua style drifts silently. Adding a `stylua --check` step catches formatting regressions on every PR at near-zero cost. (Nix formatting is intentionally left out: no formatter is configured in the repo, and reformatting existing Nix is out of scope.)

## Current state

File: `.github/workflows/check.yml`

```yaml
name: Check

on:
  push:
    branches: [main]
  pull_request:

jobs:
  flake:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: cachix/install-nix-action@v25
        with:
          extra_nix_config: |
            experimental-features = nix-command flakes

      - name: Prepare hardware configuration stub
        run: |
          if [ ! -f hosts/laptop/hardware-configuration.nix ]; then
            cp hosts/laptop/hardware-configuration.nix.example hosts/laptop/hardware-configuration.nix
          fi

      - name: Flake check
        run: nix flake check

      - name: Dry-build system configuration
        run: nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link
```

`.stylua.toml` at repo root:

```toml
column_width = 120
indent_type = "Spaces"
indent_width = 2
```

Lua files live under `modules/desktop/hyprland/`. Quickshell is QML (no formatter). Nix has no configured formatter.

Repo convention: existing Lua files are already stylua-compliant (verified informally; `stylua --check` on the tree should pass today).

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Local Lua style check | `stylua --check $(find modules -name '*.lua')` | exit 0 (all files already compliant) |
| CI workflow validity | (CI runs on push/PR; no local validator required beyond YAML parse) | — |

## Scope

**In scope**:
- `.github/workflows/check.yml`

**Out of scope**:
- `.stylua.toml` (do not change config).
- Any `.lua` reformatting (if `stylua --check` fails locally, that's a separate pre-existing finding — report it, don't fix in this plan).
- Nix formatting / alejandra / nixfmt (not configured; out of scope).
- QML formatting (no tooling).

## Git workflow

- Branch: `advisor/004-ci-bump-and-stylua-gate`
- Commit: `ci: bump install-nix-action, add stylua gate`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Bump `cachix/install-nix-action@v25` → `@v27`

In `.github/workflows/check.yml`, change:

```yaml
      - uses: cachix/install-nix-action@v25
```

to:

```yaml
      - uses: cachix/install-nix-action@v27
```

(v27 is the current major; it's a drop-in for v25 with the `extra_nix_config` input unchanged.)

**Verify**: `grep -n "install-nix-action" .github/workflows/check.yml` → shows `@v27`.

### Step 2: Add a `stylua --check` step

Add a new job (parallel to `flake`) so a formatting failure doesn't block the slower Nix build, and so Nix isn't required to install stylua. Insert after the `flake` job:

```yaml
  stylua:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: JohnnyMorganz/stylua-action@v4
        with:
          version: latest
          token: ${{ secrets.GITHUB_TOKEN }}
          args: --check $(find modules -name '*.lua')
```

Notes:
- `JohnnyMorganz/stylua-action@v4` is the official StyLua action; it reads `.stylua.toml` from the repo root automatically.
- `--check` exits non-zero if any file would be reformatted — gate behavior, no writes.
- The `find modules -name '*.lua'` covers all Lua under `modules/` (the only Lua in the repo).

**Verify**: `grep -n "stylua-action" .github/workflows/check.yml` → one match.

### Step 3: Confirm local compliance

**Verify**: `stylua --check $(find modules -name '*.lua')` locally → exit 0. If stylua isn't installed locally, skip this gate and note it; CI will enforce it. If it fails on a file, **do not reformat** — report the file as a separate pre-existing finding (out of scope for this plan).

## Test plan

CI-only verification. On push/PR:
- `stylua` job passes (all Lua already compliant).
- `flake` job still passes with the bumped action.

If the repo doesn't run CI before merge, the operator should push to a PR branch and confirm both jobs are green.

## Done criteria

- [ ] `grep -n "install-nix-action@v27" .github/workflows/check.yml` returns a match
- [ ] `grep -n "install-nix-action@v25" .github/workflows/check.yml` returns nothing
- [ ] A `stylua` job exists in `.github/workflows/check.yml` using `JohnnyMorganz/stylua-action@v4` with `--check`
- [ ] `stylua --check $(find modules -name '*.lua')` exits 0 locally (or stylua is unavailable and CI will enforce)
- [ ] Only `.github/workflows/check.yml` is modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report if:

- `stylua --check` fails on any current Lua file — that's pre-existing style debt; report it rather than reformatting in this plan.
- `cachix/install-nix-action@v27` does not exist or has a different input shape — fall back to the latest available major and note it.
- The repo's Lua files aren't all under `modules/` (the `find` would miss some) — extend the glob and report.

## Maintenance notes

- If Nix formatting is later configured (alejandra/nixfmt), add a parallel `nix fmt --check` job; don't bolt it onto the stylua job.
- When a new `.lua` file is added outside `modules/` (unlikely — all Hyprland Lua is under `modules/desktop/hyprland/`), update the `find` path.
- Reviewer: confirm the stylua job runs `--check` (not in-place rewrite) and that it's a separate job from `flake`.
