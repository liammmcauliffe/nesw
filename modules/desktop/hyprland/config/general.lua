--[[
  General Layout & Gaps
  Master layout, gap sizes, and border colors. Gap values are sized so the
  Quickshell border/notch (4px inset) leaves even spacing around tiled windows.
]]

local vars = require("variables")

hl.config({
    general = {
        layout          = "master",

        allow_tearing   = false, -- required for the `immediate` window rule used by games

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

    dwindle = {
        preserve_split = true,
        smart_split    = false,
        smart_resizing = true,
    },

    scrolling = {
        fullscreen_on_one_column = true,
        focus_fit_method         = 1,
        column_width             = 0.5,
        follow_focus             = true,
        follow_min_visible       = 0.0,
        -- Discrete column widths make Super+Alt resize feel predictable on ultrawides
        explicit_column_widths   = "0.35, 0.5, 0.65, 1.0",
    },
})
