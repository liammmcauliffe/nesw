function kill-ui --description "Kill Quickshell and Hyprland"
    echo "Killing Quickshell and Hyprland..."
    systemctl --user stop quickshell.service 2>/dev/null || true
    killall -9 Hyprland 2>/dev/null || true
end
