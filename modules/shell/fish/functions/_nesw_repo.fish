function _nesw_repo --description "Enter ~/nesw or fail"
    if not test -d ~/nesw
        echo "✗ ~/nesw not found"
        return 1
    end
    pushd ~/nesw
end
