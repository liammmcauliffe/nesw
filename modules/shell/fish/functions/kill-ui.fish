function kill-ui --description "Kill Quickshell and Hyprland"
    echo "Killing Quickshell and Hyprland..."
    pkill -f "qs -c nesw" 2>/dev/null
    if command -q hyprctl
        hyprctl dispatch 'hl.dsp.exit()'
    end
end
