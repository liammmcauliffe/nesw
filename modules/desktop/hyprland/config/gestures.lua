local vars = require("variables")

-- swipe tuning
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

hl.gesture({ fingers = vars.workspaceSwipeFingers, direction = "horizontal", action = "workspace" })
hl.gesture({ fingers = vars.gestureFingers, direction = "up", action = "special", arg = "special" })
hl.gesture({
    fingers = vars.gestureFingersMore,
    direction = "down",
    action = function()
        hl.exec_cmd(vars.suspendCommand)
    end,
})
