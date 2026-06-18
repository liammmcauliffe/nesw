function nswitch --description "Stage all, rebuild and switch to new config"
    _nesw_repo || return 1
    _nesw_stage || begin; popd; return 1; end
    set -l t0 (date +%s)
    echo "→ rebuilding..."
    if sudo nixos-rebuild switch --flake .#$NESW_HOST $argv
        echo "✓ done in "(math (date +%s) - $t0)"s"
        popd
    else
        echo "✗ rebuild failed"
        popd
        return 1
    end
end
