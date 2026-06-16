--[[
  Hyprland entry point (0.55+ loads ~/.config/hypr/hyprland.lua directly).
  require() resolves under ~/.config/hypr/ - no repo path or NESW_DIR needed.
]]

hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

require("config.env")
require("config.general")
require("config.input")
require("config.misc")
require("config.animations")
require("config.decoration")

require("config.execs")
require("config.rules")
require("config.gestures")
require("config.keybinds")

require("variables")
