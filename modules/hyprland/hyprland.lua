local home = ps.getenv("HOME")
local hyprland = home .. "/nesw/modules/hyprland"
package.path = package.path .. ";" .. home .. "/nesw/modules/hyprland/?.lua"

local function maybe_create(file)
    local f = io.open(file)
    if not f then
        os.execute("touch " .. file)
    else
        f:close()
    end
end
