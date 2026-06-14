hl.config({
    animations = {
        enabled = true,
    },
})

-- animation curves
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },    { 0.32, 1 }    } })
hl.curve("easeInQuint",    { type = "bezier", points = { { 0.64, 0 },    { 0.78, 0 }    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 }    } })
hl.curve("linear",         { type = "bezier", points = { { 0, 0 },       { 1, 1 }       } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },   { 0.75, 1 }    } })
hl.curve("quick",          { type = "bezier", points = { { 0.1, 0 },     { 0.0, 1 }     } })

-- time-bound overshoot beziers (workspaces / layers)
hl.curve("overshoot",      { type = "bezier", points = { { 0.34, 1.25 }, { 0.5, 1 }     } })
hl.curve("overshootSoft",  { type = "bezier", points = { { 0.3, 1.12 },  { 0.5, 1 }     } })

-- animation configs
hl.animation({ leaf = "global",        enabled = true, speed = 5,    bezier = "default" })
hl.animation({ leaf = "border",        enabled = true, speed = 4,    bezier = "default" })
hl.animation({ leaf = "windows",       enabled = true, speed = 5,    bezier = "easeOutQuint", style = "slide bottom" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 6,    bezier = "easeOutQuint", style = "slide bottom" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 5,    bezier = "easeInQuint",  style = "slide top" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5,    bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeIn",       enabled = true, speed = 4,    bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeOut",      enabled = true, speed = 4,    bezier = "easeInQuint" })
hl.animation({ leaf = "fade",         enabled = true, speed = 4,    bezier = "easeOutQuint" })
hl.animation({ leaf = "layers",       enabled = true, speed = 4,    bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",     enabled = true, speed = 4,    bezier = "easeOutQuint", style = "slide bottom" })
hl.animation({ leaf = "layersOut",    enabled = true, speed = 4,    bezier = "easeInQuint",  style = "slide bottom" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 4, bezier = "easeOutQuint" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 4, bezier = "easeInQuint" })
hl.animation({ leaf = "workspaces",    enabled = true, speed = 5,    bezier = "overshoot",     style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 5,    bezier = "overshoot",     style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 5,    bezier = "overshoot",     style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true, speed = 6,    bezier = "quick" })
