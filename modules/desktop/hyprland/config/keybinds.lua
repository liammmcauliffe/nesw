--[[
  Keybindings
  Binds workspace navigation, window management, apps, and media keys. Modifier
  prefixes live in variables.lua (generated from Nix) so remapping a group is one edit.
]]

local vars = require("variables")
local fn = require("config.functions")

-- Jump by ±10 workspaces for the grouped layout (rows of 10)
local function ws_jump(step)
    return function()
        local active_ws = hl.get_active_workspace()
        if not active_ws then
            return
        end

        local current = active_ws.id
        local target = current + step

        if step < 0 and current < 10 then
            target = 1
        end

        if target < 1 then
            target = 1
        end

        hl.dispatch(hl.dsp.focus({ workspace = target }))
    end
end

-- Number keys 1–0 target workspace slots and groups (see config/functions.lua)
for i = 1, 10 do
    local key = i % 10
    hl.bind(vars.kbGoToWs .. " + " .. key, fn.ws_action(false, "w", i))
    hl.bind(vars.kbMoveWinToWs .. " + " .. key, fn.ws_action(true, "w", i))
    hl.bind(vars.kbGoToWsGroup .. " + " .. key, fn.ws_action(false, "g", i))
    hl.bind(vars.kbMoveWinToWsGroup .. " + " .. key, fn.ws_action(true, "g", i))
end

-- Adjacent workspace navigation (keyboard and scroll wheel)
hl.bind(vars.kbNextWsMouse, hl.dsp.focus({ workspace = "-1" }))
hl.bind(vars.kbPrevWsMouse, hl.dsp.focus({ workspace = "+1" }))
hl.bind(vars.kbPrevWs, hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind(vars.kbNextWs, hl.dsp.focus({ workspace = "+1" }), { repeating = true })
hl.bind("SUPER + Page_Up", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
hl.bind("SUPER + Page_Down", hl.dsp.focus({ workspace = "+1" }), { repeating = true })

-- Workspace group navigation (±10) for the 10-wide grid
hl.bind(vars.kbNextWsGroupMouse, hl.dsp.focus({ workspace = "-10" }))
hl.bind(vars.kbPrevWsGroupMouse, hl.dsp.focus({ workspace = "+10" }))
hl.bind("SUPER + grave", ws_jump(-10))
hl.bind("SUPER + Minus", ws_jump(10))

-- Scratchpad-style special workspace (see config/gestures.lua for swipe target)
hl.bind(vars.kbToggleSpecialWs, hl.dsp.workspace.toggle_special("special"))

-- Move focused window across workspaces without changing focus
hl.bind("SUPER + ALT + Page_Up", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
hl.bind("SUPER + ALT + Page_Down", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind(vars.kbMoveWinNextWsMouse, hl.dsp.window.move({ workspace = "-1" }))
hl.bind(vars.kbMoveWinPrevWsMouse, hl.dsp.window.move({ workspace = "+1" }))
hl.bind("CTRL + SUPER + SHIFT + right", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
hl.bind("CTRL + SUPER + SHIFT + left", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })

-- Send window to/from the special workspace
hl.bind("CTRL + SUPER + SHIFT + up", hl.dsp.window.move({ workspace = "special:special" }))
hl.bind("CTRL + SUPER + SHIFT + down", hl.dsp.window.move({ workspace = "e+0" }))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "special:special" }))


-- Tab cycles within a window group; lock prevents accidental ungroup during resize
hl.bind(vars.kbWindowGroupCycleNext, hl.dsp.window.cycle_next({ next = true }), { repeating = true })
hl.bind(vars.kbWindowGroupCyclePrev, hl.dsp.window.cycle_next({ next = false }), { repeating = true })
hl.bind("CTRL + ALT + Tab", hl.dsp.group.next(), { repeating = true })
hl.bind("CTRL + SHIFT + ALT + Tab", hl.dsp.group.prev(), { repeating = true })
hl.bind(vars.kbToggleGroup, hl.dsp.group.toggle())
hl.bind(vars.kbUngroup, hl.dsp.window.move({ out_of_group = true }))
hl.bind("SUPER + SHIFT + Comma", hl.dsp.group.lock_active())


-- Directional focus/move/resize - Super+Alt resize is relative for fine adjustments
hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + ALT + left", hl.dsp.window.resize(fn.resize_active_window(-10, 0)), { repeating = true })
hl.bind("SUPER + ALT + right", hl.dsp.window.resize(fn.resize_active_window(10, 0)), { repeating = true })
hl.bind("SUPER + ALT + up", hl.dsp.window.resize(fn.resize_active_window(0, -10)), { repeating = true })
hl.bind("SUPER + ALT + down", hl.dsp.window.resize(fn.resize_active_window(0, 10)), { repeating = true })

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(vars.kbMoveWindow, hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(vars.kbResizeWindow, hl.dsp.window.resize(), { mouse = true })
hl.bind("CTRL + SUPER + Backslash", hl.dsp.window.center())
hl.bind("CTRL + SUPER + ALT + Backslash", function()
    local size = fn.resize_by_screen(55, 70)
    if size then
        hl.dispatch(hl.dsp.window.resize(size))
    end
    hl.dispatch(hl.dsp.window.center())
end)
hl.bind(vars.kbWindowPip, function()
    local a = hl.get_active_window()
    if a then
        local pip = fn.move_actions() or {}
        table.insert(pip, hl.dsp.window.pin())
        fn.resizer(a.title, 0, 0, pip, true)
    end
end)
hl.bind(vars.kbPinWindow, hl.dsp.window.pin())
hl.bind(vars.kbWindowFullscreen, hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(vars.kbWindowBorderedFullscreen, hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(vars.kbToggleWindowFloating, hl.dsp.window.float())
hl.bind(vars.kbCloseWindow, hl.dsp.window.close())

-- Default apps: app2unit scopes launches to the focused monitor's systemd unit
hl.bind(vars.kbTerminal, hl.dsp.exec_cmd("app2unit -- " .. vars.terminal))
hl.bind(vars.kbBrowser, hl.dsp.exec_cmd("app2unit -- " .. vars.browser))
-- Launcher toggles the Quickshell IPC target defined in modules/desktop/quickshell
hl.bind(vars.kbLauncher, hl.dsp.exec_cmd("qs ipc call launcher toggle"))
hl.bind(vars.kbSession, hl.dsp.exec_cmd("qs ipc call logout toggle"), { locked = true })
hl.bind(vars.kbScreenshot, hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

-- PipeWire volume keys: unmute before raise so hardware mute does not block steps
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind("SUPER + SHIFT + M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%+"
    ),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-mute @DEFAULT_AUDIO_SINK@ 0; wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ " .. vars.volumeStep .. "%-"
    ),
    { locked = true, repeating = true }
)

-- Suspend bind mirrors the three-finger down gesture in config/gestures.lua
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd(vars.suspendCommand), { locked = true })
