local vars = require("variables")

local graphicalSessionCmd =
    "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
        .. " && systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
        .. " && systemctl --user start graphical-session.target"

hl.on("hyprland.start", function()
    os.execute(graphicalSessionCmd)

    hl.exec_cmd("qs -c nesw")

    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("trash-empty 30")

    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    hl.exec_cmd("mpris-proxy")
end)

hl.on("hyprland.shutdown", function()
    os.execute("systemctl --user stop graphical-session.target 2>/dev/null || true")
end)
