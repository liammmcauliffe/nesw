--[[
  Hyprland Autostart & Session Hooks
  Runs once at compositor startup: secrets, clipboard history, Quickshell, and
  cursor theme sync. Keeps long-running services out of individual keybinds.
]]

local vars = require("variables")
local home = os.getenv("HOME") or error("HOME not set")
local nesw_dir = os.getenv("NESW_DIR") or (home .. "/nesw")
local quickshell_config = nesw_dir .. "/modules/desktop/quickshell/config"

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

    -- Quickshell provides the top bar, notch, and launcher; started from the live repo path
    hl.exec_cmd("qs -p " .. quickshell_config)
end)
