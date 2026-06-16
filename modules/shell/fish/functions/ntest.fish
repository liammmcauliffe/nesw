function ntest --description "Stage all, rebuild and test config (reverts on reboot)"
    _nesw_repo || return 1
    _nesw_stage || begin; popd; return 1; end
    set -l t0 (date +%s)
    echo "→ testing (revert on reboot)..."
    if sudo nixos-rebuild test --flake .#main $argv
        echo "✓ done in "(math (date +%s) - $t0)"s - reboot to revert"
        popd
    else
        echo "✗ test build failed"
        popd
        return 1
    end
end
