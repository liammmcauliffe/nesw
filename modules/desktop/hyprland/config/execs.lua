--[[
  Hyprland Autostart & Session Hooks
  Runs once at compositor startup: secrets, clipboard history, and cursor theme sync.
  Quickshell is started by the Home Manager systemd user service (qs -c nesw).
]]

local vars = require("variables")

hl.on("hyprland.start", function()

    -- GNOME keyring holds credentials for apps that expect a freedesktop secret service
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

    -- cliphist needs a wl-paste watcher per mime type to build searchable history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")

    -- Prune old trash automatically so the home partition does not fill silently
    hl.exec_cmd("trash-empty 30")

    -- Hyprland and GTK read cursor settings separately; sync both at login
    hl.exec_cmd("hyprctl setcursor " .. vars.cursorTheme .. " " .. vars.cursorSize)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme " .. vars.cursorTheme)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-size " .. vars.cursorSize)

    -- Bluetooth headsets often need mpris-proxy to receive play/pause from the WM
    hl.exec_cmd("mpris-proxy")

    -- Start HM graphical-session.target so Quickshell and other user services launch
    hl.exec_cmd("systemctl --user start graphical-session.target")
end)
