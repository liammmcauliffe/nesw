-- local scheme = require("scheme.current")

return {
    -- Apps
    terminal = "ghostty",
    browser = "zen-beta",

    -- Touchpad
    touchpadDisableTyping = true,
    touchScrollFactor = 0.1,
    gestureFingers = 3,
    workspaceSwipeFingers = 4,
    gestureFingersMore = 4,

    -- Blur
    blurEnabled = true,
    blurSpecialWs = false,
    blurPopups = true,
    blurInputMethods = true,
    blurSize = 8,
    blurPasses = 2,
    blurXray = false,

    -- Shadow
    shadowEnabled = true,
    shadowRange = 20,
    shadowRenderPower = 3,
    -- shadowColour = "rgba(" .. scheme.surface .. "d4)",

    -- Gaps
    workspaceGaps = 20,
    windowGapsIn = 4,
    windowGapsOut = 8,
    singleWindowGapsOut = 16,

    -- Window Styling
    windowOpacity = 0.95,
    windowRounding = 15,
    windowBorderSize = 1,
    -- activeWindowBorderColour = "rgba(" .. scheme.primary .. "e6)",
    -- inactiveWindowBorderColour = "rgba(" .. scheme.onSurfaceVariant .. "11)",
    
    -- Misc
    volumeStep = 5,
    cursorTheme = "Bibata-Modern-Ice",
    cursorSize = 20,
    suspendCommand = "systemctl suspend",

    -- KEYBINDS
    -- Workspaces
    kbMoveWinToWs = "SUPER + ALT",
    kbMoveWinToWsGroup = "CTRL + SUPER + ALT",
    kbGoToWs = "SUPER",
    kbGoToWsGroup = "CTRL + SUPER",
    kbNextWs = "CTRL + SUPER + Right",
    kbPrevWs = "CTRL + SUPER + Left",
    kbToggleSpecialWs = "SUPER + S",

    -- Window Group
    kbWindowGroupCycleNext = "ALT + TAB",
    kbWindowGroupCyclePrev = "SHIFT + ALT + TAB",
    kbUngroup = "SUPER + U",
    kbToggleGroup = "SUPER + Comma",

    -- Window Action
    kbMoveWindow = "SUPER + Z",
    kbResizeWindow = "SUPER + X",
    kbWindowPip = "SUPER + ALT + backslash",
    kbPinWindow = "SUPER + P",
    kbWindowFullscreen = "SUPER + F",
    kbWindowBorderedFullscreen = "SUPER + ALT + F",
    kbToggleWindowFloating = "SUPER + ALT + space",
    kbCloseWindow = "SUPER + Q",

    -- Special workspaces toggles
    kbMusic = "SUPER + M",
    kbCommunication = "SUPER + D",

    -- Apps
    kbTerminal = "SUPER + Return",
    kbBrowser = "SUPER + W",

    -- Misc
    kbSession = "CTRL + ALT + Delete",
}
