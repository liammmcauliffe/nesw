local vars = require("variables")

hl.config({
    general = {
        layout          = "master",

        allow_tearing   = false,

        gaps_workspaces = vars.workspaceGaps,
        gaps_in         = vars.windowGapsIn,
        gaps_out        = vars.windowGapsOut,
        border_size     = vars.windowBorderSize,

        col             = {
            active_border   = vars.activeWindowBorderColor,
            inactive_border = vars.inactiveWindowBorderColor,
        },
    },

    master = {
        new_status  = "master",
        mfact       = 0.50,
        orientation = "right",
        new_on_top  = true,
    },
})
