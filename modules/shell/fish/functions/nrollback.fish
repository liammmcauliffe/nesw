function nrollback --description "Rollback to the previous system generation"
    sudo nixos-rebuild switch --rollback
    echo "Rolled back system. Reboot or restart your session to apply."
end
