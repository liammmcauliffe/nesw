local vars = require("variables")

-- window rules
hl.window_rule({ match = { fullscreen = false }, opacity = vars.windowOpacity .. " override" })
hl.window_rule({ match = { float = true, xwayland = false }, center = true })

-- float
hl.window_rule({ match = { class = "yad|zenity|wev|feh|imv|blueman-manager|system-config-printer" }, float = true })
hl.window_rule({ match = { class = "org.gnome.FileRoller|file-roller" }, float = true })
hl.window_rule({ match = { class = "com.github.GradienceTeam.Gradience" }, float = true })

-- float + resize
hl.window_rule({ match = { class = "foot", title = "nmtui" }, float = true, size = "(monitor_w*0.7) (monitor_h*0.6)", center = true })
hl.window_rule({ match = { class = "org.gnome.Settings" }, float = true, size = "(monitor_w*0.8) (monitor_h*0.7)", center = true })
hl.window_rule({ match = { class = "org.pulseaudio.pavucontrol|yad-icon-browser" }, float = true, size = "(monitor_w*0.7) (monitor_h*0.6)", center = true })
hl.window_rule({ match = { class = "nwg-look" }, float = true, size = "(monitor_w*0.6) (monitor_h*0.5)", center = true })

-- dialogs
hl.window_rule({ match = { title = "(Select|Open)( a)? (File|Folder)(s)?" }, float = true })
hl.window_rule({ match = { title = "File (Operation|Upload)( Progress)?" }, float = true })
hl.window_rule({ match = { title = ".* Properties" }, float = true })
hl.window_rule({ match = { title = "Export Image as PNG" }, float = true })
hl.window_rule({ match = { title = "Save As" }, float = true })
hl.window_rule({ match = { title = "Library" }, float = true })

-- picture in picture
hl.window_rule({ match = { title = "Picture(-| )in(-| )[Pp]icture" }, move = "(monitor_w-(window_w*0.2)) (monitor_h-(window_h*0.3))" })
hl.window_rule({ match = { title = "Picture(-| )in(-| )[Pp]icture" }, keep_aspect_ratio = true, float = true, pin = true })

-- opaque
hl.window_rule({ match = { class = "krita|gimp|inkscape|darktable|resolve|kdenlive|shotcut|blender|godot" }, opaque = true })

-- steam
hl.window_rule({ match = { class = "steam" }, rounding = 10 })
hl.window_rule({ match = { class = "steam", title = "Friends List" }, float = true })
hl.window_rule({ match = { class = "(steam_app_(default|[0-9]+))|gamescope" }, opaque = true })
hl.window_rule({ match = { class = "(steam_app_(default|[0-9]+))|gamescope" }, immediate = true })
hl.window_rule({ match = { class = "(steam_app_(default|[0-9]+))|gamescope" }, idle_inhibit = "always" })

-- xwayland popups
hl.window_rule({ match = { xwayland = true, title = "win[0-9]+" }, no_dim = true, no_shadow = true, rounding = 10 })

-- workspace rules
hl.workspace_rule({ workspace = "w[tv1]s[false]", gaps_out = vars.singleWindowGapsOut })
hl.workspace_rule({ workspace = "f[1]s[false]", gaps_out = vars.singleWindowGapsOut })

-- layer rules
hl.layer_rule({ match = { namespace = "hyprpicker" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "logout_dialog" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "selection" }, animation = "fade" })
hl.layer_rule({ match = { namespace = "launcher" }, animation = "popin 80%", blur = true })
-- ignore_alpha keeps the blur off the transparent area under the corner fillets
hl.layer_rule({ match = { namespace = "nesw-topbar" }, blur = true, ignore_alpha = 0.1 })