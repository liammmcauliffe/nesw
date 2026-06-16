set fish_greeting ""

# ── NixOS rebuild helpers ─────────────────────────────────────────────────────
# Flakes only see git-tracked files — helpers stage before rebuild.
# local.nix is gitignored; copy from local.nix.example for machine overrides.

function _nesw_repo --description "Enter ~/nesw or fail"
    if not test -d ~/nesw
        echo "✗ ~/nesw not found"
        return 1
    end
    pushd ~/nesw
end

function _nesw_stage --description "Stage changes unless a merge is in progress"
    if test -f .git/MERGE_HEAD
        echo "✗ merge in progress — resolve conflicts before rebuilding"
        return 1
    end
    git add -A
    set -l staged (git diff --cached --stat)
    if test -n "$staged"
        echo $staged
    end
end

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

function ntest --description "Stage all, rebuild and test config (reverts on reboot)"
    _nesw_repo || return 1
    _nesw_stage || begin; popd; return 1; end
    set -l t0 (date +%s)
    echo "→ testing (revert on reboot)..."
    if sudo nixos-rebuild test --flake .#main $argv
        echo "✓ done in "(math (date +%s) - $t0)"s — reboot to revert"
        popd
    else
        echo "✗ test build failed"
        popd
        return 1
    end
end

function nupdate --description "Update all flake inputs, test build, stage lockfile"
    _nesw_repo || return 1
    if test -f .git/MERGE_HEAD
        echo "✗ merge in progress — resolve conflicts before updating"
        popd
        return 1
    end
    echo "→ updating flake inputs..."
    if not nix flake update --flake .
        echo "✗ flake update failed"
        popd
        return 1
    end
    git add flake.lock
    set -l t0 (date +%s)
    echo "→ testing updated inputs (revert on reboot)..."
    if sudo nixos-rebuild test --flake .#main
        echo "✓ inputs updated and tested in "(math (date +%s) - $t0)"s — run nswitch to keep, or reboot to revert"
        popd
    else
        echo "✗ test build failed — reboot to revert, or run nix flake update to retry"
        popd
        return 1
    end
end

function nrollback --description "Rollback to the previous system generation"
    sudo nixos-rebuild switch --rollback
end

# ── eza aliases ───────────────────────────────────────────────────────────────
function ls; eza --icons $argv; end
function ll; eza -la --icons --git $argv; end
function lt; eza --tree --icons $argv; end
