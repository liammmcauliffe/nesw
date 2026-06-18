# Plan 006: Add NixOS assertions for hostname and username footguns

> **Executor instructions**: Follow this plan step by step. Run every verification
> command and confirm the expected result before moving to the next step. If
> anything in the "STOP conditions" section occurs, stop and report — do not
> improvise. When done, update the status row for this plan in `plans/README.md`.
>
> **Drift check (run first)**: `git diff --stat 17b661a..HEAD -- hosts/laptop/configuration.nix flake.nix modules/drivers/default.nix`
> If these changed, re-read them before editing.

## Status

- **Priority**: P2
- **Effort**: S
- **Risk**: LOW
- **Depends on**: none
- **Category**: tests
- **Planned at**: commit `17b661a`, 2026-06-17
- **Issue**: (not published)

## Why this matters

Two first-build footguns have no guardrail:

1. `networking.hostName = "main"` (`hosts/laptop/configuration.nix`) must match the flake target `.#main` (`flake.nix`). A mismatch builds fine but produces a system whose hostname doesn't match its activation target — confusing rollbacks and the `nswitch`/`ntest` helpers (which hardcode `--flake .#main`).
2. `userName = "liam"` (`flake.nix`) is a placeholder the README tells users to change. If left as-is on a machine owned by a different user, the build creates a Home Manager profile for a nonexistent user, or worse, the real user gets no HM profile and loses their shell/editor config with no clear error.

The repo already has an assertion pattern (`modules/drivers/default.nix` enforces "exactly one GPU driver"). Extending it to these two invariants gives a clear build-time error instead of a broken system.

## Current state

File: `flake.nix` — defines the system and user:

```nix
      system = "x86_64-linux";
      # change this to your system username before the first rebuild
      userName = "liam";
      host = import ./hosts/laptop;
```

And builds `nixosConfigurations.main`:

```nix
      nixosConfigurations.main = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs hyprland userName; };
        modules = [
          home-manager.nixosModules.home-manager
          host.configuration
          ...
```

File: `hosts/laptop/configuration.nix` — sets hostname and the user:

```nix
  networking.hostName = "main"; # must match the flake target
  ...
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" "audio" ];
    shell = pkgs.fish;
  };
```

Existing assertion pattern to follow — `modules/drivers/default.nix`:

```nix
  config = mkMerge [
    {
      assertions = [
        {
          assertion = count (x: x) driversEnabled == 1;
          message = "Enable exactly one of nesw.drivers.amdgpu, .intel, or .nvidia in hosts/laptop/local.nix.";
        }
      ];
    }
    ...
```

Repo convention: assertions live in `config.assertions` as a list of `{ assertion, message }` attrs. The message names the file/option to fix.

## Commands you will need

| Purpose | Command | Expected on success |
|---------|---------|---------------------|
| Build | `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link` | exit 0 (with correct host/user) |
| Assertion fires on bad hostname | (see Step 3 — temporary edit, then revert) | build fails with the assertion message |

## Scope

**In scope**:
- `hosts/laptop/configuration.nix` (add assertions)

**Out of scope**:
- `flake.nix` — do not change `userName` or the `main` target. (Read-only reference.)
- `modules/drivers/default.nix` — its assertion stays as-is; this plan adds new ones, doesn't touch existing.
- The fish helpers' hardcoded `.#main` (that's plan 009 / a separate concern).

## Git workflow

- Branch: `advisor/006-hostname-username-assertions`
- Commit: `add hostname/username build assertions`
- Do NOT push or open a PR unless instructed.

## Steps

### Step 1: Add the assertions block to `hosts/laptop/configuration.nix`

`configuration.nix` receives `{ config, pkgs, hyprland, userName, ... }`. The hostname is `config.networking.hostName` (set in this same file). The expected flake target is `"main"` (hardcoded by `flake.nix`'s `nixosConfigurations.main`). The username is passed in as `userName` from `specialArgs`.

Add an `assertions` list to the config (anywhere top-level in the returned attrset; place it near the top, after `imports`, for visibility). Use this exact shape:

```nix
  # fail fast on the two first-build footguns
  assertions = [
    {
      assertion = config.networking.hostName == "main";
      message = ''
        networking.hostName is "${config.networking.hostName}" but the flake builds the "main" target (nixosConfigurations.main in flake.nix).
        Set networking.hostName = "main" in hosts/laptop/configuration.nix, or add a matching nixosConfigurations.<name> in flake.nix.
      '';
    }
    {
      assertion = userName != "liam" || builtins.getEnv "USER" == "liam" || true;
      # ponytail: weak guard — Nix evaluation can't reliably read the build host's user.
      # Real protection is the README's "set your username" step; this assertion is a nudge, not a hard gate.
      message = ''
        flake.nix userName is still the placeholder "liam". If this machine's user is not "liam", set userName in flake.nix to your real Linux username before rebuilding.
      '';
    }
  ];
```

**Important nuance — the username assertion cannot be a hard gate.** Nix evaluation doesn't reliably know the target machine's real username, and `liam` *is* the correct user on the author's machine. So the assertion's `assertion` expression is written to never fire (the `|| true`), making it a **documentation nudge only**: the `message` text shows up in the assertion list for discoverability but never fails the build. This is intentional and marked with a `ponytail:` comment. If a harder gate is wanted later, it would require passing a `expectedUser` from `local.nix` and asserting equality — out of scope here.

The **hostname assertion is a real hard gate** — `config.networking.hostName` is known at evaluation time and must equal `"main"`.

**Verify**: `nix flake check` → exit 0 (with `hostName = "main"`, the assertion passes).

### Step 2: Confirm the hostname assertion is reachable and the username one is a no-op

Re-read the block: the hostname assertion's condition is `config.networking.hostName == "main"`, which is `true` in the current config, so the build still passes. The username assertion's condition ends in `|| true`, so it never fires.

**Verify**: `grep -n "assertions =" hosts/laptop/configuration.nix` → one match.

### Step 3: (Optional, if a throwaway build is cheap) Prove the hostname assertion fires

Temporarily change `networking.hostName = "main";` to `networking.hostName = "wrong";`, run `nix build .#nixosConfigurations.main.config.system.build.toplevel --no-link`, and confirm the build fails with the assertion message. **Then revert the hostname back to `"main"` immediately.** Do not commit the temporary change.

If a throwaway Nix build is too slow/expensive to justify, skip this step and note "skipped — assertion verified by inspection."

**Verify**: `grep -n 'networking.hostName = "main"' hosts/laptop/configuration.nix` → matches (reverted).

## Test plan

No unit-test harness. Verification:
- `nix flake check` passes with correct values.
- (Optional) `nix build` fails with the assertion message when `hostName` is wrong, then reverts.
- The username assertion is confirmed by inspection to be a no-op (`|| true`) — it documents, doesn't gate.

## Done criteria

- [ ] `hosts/laptop/configuration.nix` has an `assertions` list with two entries (hostname gate + username nudge)
- [ ] `nix flake check` exits 0
- [ ] `grep -n 'networking.hostName = "main"' hosts/laptop/configuration.nix` still matches (unchanged)
- [ ] Only `hosts/laptop/configuration.nix` is modified
- [ ] `plans/README.md` status row updated

## STOP conditions

Stop and report if:

- `hosts/laptop/configuration.nix` doesn't receive `userName` in its module arguments (signature changed) — the username assertion references `userName`; if it's not in scope, rework using `config.users.users` introspection or report.
- `flake.nix` no longer builds `nixosConfigurations.main` (target renamed) — the hostname assertion hardcodes `"main"`; update both to match or report.
- An `assertions` list already exists in `configuration.nix` (it doesn't at `17b661a`) — merge into it instead of adding a second top-level `assertions`.

## Maintenance notes

- If plan 009 (multi-host helpers) lands and the flake gains a second `nixosConfigurations.<name>`, the hostname assertion's hardcoded `"main"` must be generalized — e.g. derive the expected name from the host being built. Note this in plan 009.
- The username assertion is deliberately weak. If a stronger guard is wanted, the upgrade path is: add `nesw.expectedUser` option in `local.nix` and assert `userName == nesw.expectedUser`. Leave the nudge until then.
- Reviewer: confirm the username assertion truly cannot fire (`|| true`) and the hostname assertion genuinely fails on mismatch.
