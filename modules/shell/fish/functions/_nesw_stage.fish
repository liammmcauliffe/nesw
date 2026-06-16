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
