function _nesw_repo --description "Enter the nesw repo, sets NESW_HOST and NESW_HOST_DIR"
    set -l repo "$NESW_DIR"
    if test -z "$repo"
        set repo ~/nesw
    end
    if not test -d "$repo"
        echo "✗ nesw repo not found (set \$NESW_DIR or clone at ~/nesw)"
        return 1
    end
    pushd "$repo"
    set -gx NESW_HOST main
    set -gx NESW_HOST_DIR hosts/laptop
end
