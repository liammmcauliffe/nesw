function _nesw_stage --description "Stage changes unless a merge is in progress"
    if test -f .git/MERGE_HEAD
        echo "✗ merge in progress — resolve conflicts before rebuilding"
        return 1
    end
    git add -A
    # Flakes ignore gitignored files — force-stage machine-specific configs
    for f in \
        hosts/laptop/hardware-configuration.nix \
        hosts/laptop/local.nix \
        hosts/laptop/shared.nix \
        hosts/laptop/home.local.nix
        if test -f $f
            git add -f $f
        end
    end
    set -l staged (git diff --cached --stat)
    if test -n "$staged"
        echo $staged
    end
end
