local vars = require("variables")

-- gesture config
hl.config({
    gestures = {
        workspace_swipe = true,
        workspace_swipe_fingers = vars.workspaceSwipeFingers,
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.15,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true,
    },
})

-- gestures
hl.gesture({ fingers = vars.gestureFingers, direction = "up", action = "special", arg = "special" })
hl.gesture({
    fingers = vars.gestureFingersMore,
    direction = "down",
    action = function()
        hl.exec_cmd(vars.suspendCommand)
    end,
})
