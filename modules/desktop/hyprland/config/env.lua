--[[
  Session Environment Variables
  Sets Wayland/XDG env vars so Qt, GTK, Electron, and SDL apps behave correctly
  under Hyprland. NESW_DIR lets Lua configs find the repo when it is not at ~/nesw.
]]

local vars = require("variables")

local home = os.getenv("HOME") or ""
local nesw_dir = os.getenv("NESW_DIR") or (home .. "/nesw")
hl.env("NESW_DIR", nesw_dir)

-- Qt theming and cursor vars keep toolkit apps consistent with the GTK cursor theme
hl.env("QT_QPA_PLATFORMTHEME", "qtengine")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("XCURSOR_THEME", vars.cursorTheme)
hl.env("XCURSOR_SIZE", vars.cursorSize)

-- Prefer native Wayland backends but keep X11 fallbacks for older toolkits
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("SDL_VIDEODRIVER", "wayland,x11,windows")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- XDG hints help portals, screen sharing, and desktop file associations
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

-- Java AWT needs this on tiling WMs to avoid misplaced child windows
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")
