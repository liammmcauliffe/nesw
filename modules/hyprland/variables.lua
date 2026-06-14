-- local scheme = require("scheme.current")

return {
    -- apps
    terminal = "ghostty",
    browser = "zen-beta",

    -- touchpad
    touchpadDisableTyping = false,
    touchpadScrollFactor = 0.4,
    gestureFingers = 3,
    workspaceSwipeFingers = 4,
    gestureFingersMore = 4,

    -- blur
    blurEnabled = true,
    blurSpecialWs = false,
    blurPopups = true,
    blurInputMethods = true,
    blurSize = 8,
    blurPasses = 2,
    blurXray = false,

    -- shadow
    shadowEnabled = false,
    shadowRange = 10,
    shadowRenderPower = 2,
    -- shadowColor = "rgba(" .. scheme.surface .. "d4)",

    -- gaps
    -- the 6px screen border sits inside gaps_out, so the visible gap between
    -- windows and the border/notch is (windowGapsOut - 6) on all sides
    workspaceGaps = 12,
    windowGapsIn = 4,
    windowGapsOut = 12,
    singleWindowGapsOut = 12,

    -- window styling
    windowOpacity = 0.95,
    windowRounding = 15,
    windowBorderSize = 1,
    -- activeWindowBorderColor = "rgba(" .. scheme.primary .. "e6)",
    -- inactiveWindowBorderColor = "rgba(" .. scheme.onSurfaceVariant .. "11)",

    -- misc
    volumeStep = 5,
    cursorTheme = "Bibata-Modern-Ice",
    cursorSize = 20,
    suspendCommand = "systemctl suspend",

    -- keybinds
    -- workspaces
    kbMoveWinToWs = "SUPER + CTRL",
    kbMoveWinToWsGroup = "SUPER + CTRL + SHIFT + ALT",
    kbGoToWs = "SUPER",
    kbGoToWsGroup = "SUPER + CTRL + ALT",
    kbNextWs = "CTRL + SUPER + Right",
    kbPrevWs = "CTRL + SUPER + Left",
    kbNextWsMouse = "SUPER + mouse_down",
    kbPrevWsMouse = "SUPER + mouse_up",
    kbNextWsGroupMouse = "CTRL + SUPER + mouse_down",
    kbPrevWsGroupMouse = "CTRL + SUPER + mouse_up",
    kbMoveWinNextWsMouse = "SUPER + ALT + mouse_down",
    kbMoveWinPrevWsMouse = "SUPER + ALT + mouse_up",
    kbToggleSpecialWs = "SUPER + S",

    -- window groups
    kbWindowGroupCycleNext = "ALT + TAB",
    kbWindowGroupCyclePrev = "SHIFT + ALT + TAB",
    kbUngroup = "SUPER + U",
    kbToggleGroup = "SUPER + Comma",

    -- window actions
    kbMoveWindow = "SUPER + Z",
    kbResizeWindow = "SUPER + X",
    kbWindowPip = "SUPER + ALT + backslash",
    kbPinWindow = "SUPER + P",
    kbWindowFullscreen = "SUPER + F",
    kbWindowBorderedFullscreen = "SUPER + ALT + F",
    kbToggleWindowFloating = "SUPER + ALT + space",
    kbCloseWindow = "SUPER + Q",

    -- special workspaces toggles
    kbMusic = "SUPER + M",
    kbCommunication = "SUPER + D",

    -- apps
    kbTerminal = "SUPER + Return",
    kbBrowser = "SUPER + W",
    kbLauncher = "SUPER + space",

    -- misc
    kbSession = "CTRL + ALT + Delete",
}
