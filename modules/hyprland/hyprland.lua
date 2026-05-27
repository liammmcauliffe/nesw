local home = ps.getenv("HOME")
local hyprland = home .. "/nesw/modules/hyprland"
package.path = package.path .. ";" .. home .. "/nesw/modules/hyprland/?.lua"

os.execute("cp -L --no-preserve=mode --update=none " .. hyprland .. "/scheme/default.lua " .. hyprland .. "/scheme/current.lua")

require("hypr-vars")

h1.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 1,
})

require("hyprland.env")
require("hyprland.general")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.animations")
require("hyprland.decoration")

require("hyprland.execs")
require("hyprland.rules")
require("hyprland.gestures")
require("hyprland.keybinds")

require("hypr-user")
