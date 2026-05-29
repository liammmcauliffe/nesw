local home = os.getenv("HOME")
local hyprland = home .. "/nesw/modules/hyprland"
package.path = package.path .. ";" .. home .. "/nesw/modules/hyprland/?.lua"

-- os.execute("cp -L --no-preserve=mode --update=none " .. hyprland .. "/scheme/default.lua " .. hyprland .. "/scheme/current.lua")

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
