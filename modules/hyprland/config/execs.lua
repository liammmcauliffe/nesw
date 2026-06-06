local vars = require("variables")
local home = os.getenv("HOME")

hl.on("hyprland.start", function()

    -- keyring
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

    -- clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- auto delete trash 30 days old
    hl.exec_cmd("trash-empty 30")

    -- cursors
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- forward bluetooth media commands to mpris
    hl.exec_cmd("mpris-proxy")

    -- shell
    hl.exec_cmd("qs -p " .. home .. "/.config/quickshell")
end)
