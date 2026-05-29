hl.config({
    animations = {
        enabled = true,
    },
})

-- Animation curves
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 }    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 }    } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 }       } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 }    } })
hl.curve("quick",          { type = "bezier", points = { { 0.1, 0 },     { 0.0, 1 }     } })

-- Time-bound overshoot beziers: quick slide + subtle bounce, immune to the
-- slow-motion-under-load behaviour of physics `spring` curves.
hl.curve("overshoot",      { type = "bezier", points = { { 0.34, 1.25 }, { 0.5, 1 }     } })
hl.curve("overshootSoft",  { type = "bezier", points = { { 0.3, 1.12 },  { 0.5, 1 }     } })

-- Animation configs
hl.animation({ leaf = "global",        enabled = true, speed = 5,    bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 4,    bezier = "almostLinear" })
hl.animation({ leaf = "windows",       enabled = true, speed = 4,    bezier = "overshoot",     style = "slide" })
hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4,    bezier = "overshoot",     style = "slide" })
hl.animation({ leaf = "windowsOut",    enabled = true, speed = 4,    bezier = "easeOutQuint",  style = "slide" })
hl.animation({ leaf = "windowsMove",   enabled = true, speed = 4.5,  bezier = "overshoot" })
hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "overshootSoft", style = "slide bottom" })
hl.animation({ leaf = "layersOut",     enabled = true, speed = 3,    bezier = "linear",        style = "slide bottom" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 5,    bezier = "overshoot",     style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5,    bezier = "overshoot",     style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5,    bezier = "overshoot",     style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 6,    bezier = "quick" })