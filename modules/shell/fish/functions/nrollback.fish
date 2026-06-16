function nrollback --description "Rollback to the previous system generation"
    sudo nixos-rebuild switch --rollback
end
