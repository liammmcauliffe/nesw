local vars = require("variables")

-- Gesture config
hl.config({
    gestures = {
        workspace_swipe_distance = 700,
        workspace_swipe_cancel_ratio = 0.15,
        workspace_swipe_min_speed_to_force = 5,
        workspace_swipe_direction_lock = true,
        workspace_swipe_direction_lock_threshold = 10,
        workspace_swipe_create_new = true,
    },
})

local function ws_step(delta)
    return function()
        if delta > 0 then
            hl.dispatch(hl.dsp.focus({ workspace = "+1" }))
        else
            hl.dispatch(hl.dsp.focus({ workspace = "-1" }))
        end
    end
end

-- Gestures
hl.gesture({ fingers = vars.workspaceSwipeFingers, direction = "left", action = ws_step(1) })
hl.gesture({ fingers = vars.workspaceSwipeFingers, direction = "right", action = ws_step(-1) })
hl.gesture({ fingers = vars.gestureFingers, direction = "up", action = "special", arg = "special" })
hl.gesture({
    fingers = vars.gestureFingersMore,
    direction = "down",
    action = function()
        hl.exec_cmd(vars.suspendCommand)
    end,
})
