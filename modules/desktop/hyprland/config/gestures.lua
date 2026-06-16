--[[
  Touchpad & Trackpad Gestures
  Workspace swipes and edge gestures. Swipe distance is high to avoid accidental
  workspace changes; three-finger up toggles the special scratchpad workspace.
]]

local vars = require("variables")

-- Swipe tuning: long distance + direction lock reduces accidental workspace hops
hl.config({
    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.15,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true,
        workspace_swipe_use_r = true,
        workspace_swipe_forever = true,
    },
})

-- Hyprland 0.51+: workspace swipe is a gesture action, not a legacy toggle
hl.gesture({ fingers = vars.workspaceSwipeFingers, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = vars.gestureFingers, direction = "up", action = "special", arg = "special" })
hl.gesture({
    fingers = vars.gestureFingersMore,
    direction = "down",
    action = function()
        hl.exec_cmd(vars.suspendCommand)
    end,
})
