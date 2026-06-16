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
