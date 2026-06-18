# Multi-host derivation strategy:
# - Flake target: networking.hostName via hostnamectl (fallback /etc/hostname) → .#$NESW_HOST
# - Host config dir: $NESW_HOST_DIR if set, else hosts/$NESW_HOST, else sole hosts/* entry
# - Repo path: $NESW_DIR if set, else ~/nesw (shell env var for fish helpers only)
function _nesw_repo --description "Enter the nesw repo (NESW_DIR or ~/nesw) and fail fast; sets NESW_HOST and NESW_HOST_DIR"
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
    set -gx NESW_HOST (command -q hostnamectl; and hostnamectl hostname; or hostname 2>/dev/null; or string trim (cat /etc/hostname 2>/dev/null))
    if test -z "$NESW_HOST"
        echo "✗ could not determine hostname for flake target"
        popd
        return 1
    end
    set -l host_dir "$NESW_HOST_DIR"
    if test -z "$host_dir"
        set host_dir hosts/$NESW_HOST
    end
    if not test -d "$host_dir"
        set -l candidates hosts/*
        if test (count $candidates) -eq 1
            set host_dir $candidates[1]
        end
    end
    if not test -d "$host_dir"
        echo "✗ host config dir not found (expected hosts/$NESW_HOST or set \$NESW_HOST_DIR)"
        popd
        return 1
    end
    set -gx NESW_HOST_DIR "$host_dir"
end
