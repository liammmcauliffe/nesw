local scheme = require("scheme.current")

return {
    terminal = "ghostty",
    browser = "zen-beta",

    touchpadDisableTyping = false,
    touchpadScrollFactor = 0.2,
    gestureFingers = 3,
    workspaceSwipeFingers = 4,
    gestureFingersMore = 4,

    blurEnabled = true,
    blurSpecialWs = false,
    blurPopups = true,
    blurInputMethods = true,
    blurSize = 8,
    blurPasses = 2,
    blurXray = false,

    workspaceGaps = 18,
    windowGapsIn = 4,
    windowGapsOut = 18,
    singleWindowGapsOut = 24,

    windowOpacity = 0.95,
    windowRounding = 15,
    windowBorderSize = 2,
    activeWindowBorderColor = "rgba(" .. scheme.primary .. "e6)",
    inactiveWindowBorderColor = "rgba(" .. scheme.onSurfaceVariant .. "11)",

    volumeStep = 5,
    cursorTheme = "Bibata-Modern-Ice",
    cursorSize = 20,
    suspendCommand = "systemctl suspend",

    -- keybindings
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

    kbWindowGroupCycleNext = "ALT + Tab",
    kbWindowGroupCyclePrev = "SHIFT + ALT + Tab",
    kbUngroup = "SUPER + U",
    kbToggleGroup = "SUPER + Comma",

    kbMoveWindow = "SUPER + Z",
    kbResizeWindow = "SUPER + X",
    kbWindowPip = "SUPER + ALT + backslash",
    kbPinWindow = "SUPER + P",
    kbWindowFullscreen = "SUPER + F",
    kbWindowBorderedFullscreen = "SUPER + ALT + F",
    kbToggleWindowFloating = "SUPER + ALT + space",
    kbCloseWindow = "SUPER + Q",

    kbTerminal = "SUPER + Return",
    kbBrowser = "SUPER + W",
    kbLauncher = "SUPER + space",
    kbScreenshot = "SUPER + SHIFT + S",

    kbSession = "CTRL + ALT + Delete",
}
