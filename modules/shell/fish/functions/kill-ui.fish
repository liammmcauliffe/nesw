function kill-ui --description "Kill Quickshell and Hyprland"
    echo "Killing Quickshell and Hyprland..."
    pkill -f "qs -c nesw" 2>/dev/null
    hyprctl dispatch 'hl.dsp.exit()'
end
