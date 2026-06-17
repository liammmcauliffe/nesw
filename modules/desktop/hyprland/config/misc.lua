--[[
  Miscellaneous Compositor Settings
  VRR, splash screen, DPMS wake behavior, and debug overlays. Splash/logo are
  disabled because Quickshell provides the visible desktop chrome instead.
]]

hl.config({
    misc = {
        vrr                          = 2,
        animate_manual_resizes       = false,
        animate_mouse_windowdragging = false,
        disable_hyprland_logo        = true,
        disable_splash_rendering     = true,
        force_default_wallpaper      = 0,
        on_focus_under_fullscreen    = 2,
        allow_session_lock_restore   = true,
        middle_click_paste           = false,
        focus_on_activate            = true,
        session_lock_xray            = true,
        mouse_move_enables_dpms      = true,
        key_press_enables_dpms       = true,
    },
    debug = {
        error_position = 1
    }
})
