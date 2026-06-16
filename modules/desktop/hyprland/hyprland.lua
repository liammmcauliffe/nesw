local home = os.getenv("HOME") or error("HOME not set")
local nesw_dir = os.getenv("NESW_DIR") or (home .. "/nesw")
local hyprland_dir = nesw_dir .. "/modules/desktop/hyprland"
package.path = package.path
    .. ";"
    .. hyprland_dir
    .. "/?.lua;"
    .. hyprland_dir
    .. "/?/init.lua"

-- os.execute("cp -L --no-preserve=mode --update=none " .. hyprland_dir .. "/scheme/default.lua " .. hyprland_dir .. "/scheme/current.lua")

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
