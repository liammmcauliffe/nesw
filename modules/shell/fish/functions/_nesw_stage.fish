function _nesw_stage --description "Stage changes unless a merge is in progress"
    if test -f .git/MERGE_HEAD
        echo "✗ merge in progress - resolve conflicts before rebuilding"
        return 1
    end
    if test -z "$NESW_HOST_DIR"
        echo "✗ NESW_HOST_DIR not set (call _nesw_repo first)"
        return 1
    end
    git add -A
    for f in \
        $NESW_HOST_DIR/hardware-configuration.nix \
        $NESW_HOST_DIR/local.nix \
        $NESW_HOST_DIR/shared.nix \
        $NESW_HOST_DIR/home.local.nix
        if test -f $f
            git add -f $f
        end
    end
    set -l staged (git diff --cached --stat)
    if test -n "$staged"
        echo $staged
    end
end
