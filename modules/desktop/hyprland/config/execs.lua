local vars = require("variables")

hl.on("hyprland.start", function()
    -- chained: hl.exec_cmd is async — parallel calls raced import-environment vs graphical-session.target
    hl.exec_cmd(
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
            .. " && systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE"
            .. " && systemctl --user start graphical-session.target"
    )

    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    hl.exec_cmd("trash-empty 30")

    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    hl.exec_cmd("mpris-proxy")
end)
