# variables.lua + scheme/*.lua are generated from these values; edit here, not in repo lua
{ lib, pkgs, ... }:
let
  schemeLua = ''
    return {
        primary = "e4e4e7",
        onSurfaceVariant = "a1a1aa",
        surface = "09090b",
        surfaceContainer = "1c1c1f",
    }
  '';

  variablesLua = ''
    local scheme = require("scheme.current")

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

        -- gaps
        -- the 4px screen border sits inside gaps_out, so the visible gap between
        -- windows and the border/notch is (windowGapsOut - 4) on all sides
        workspaceGaps = 18,
        windowGapsIn = 4,
        windowGapsOut = 18,
        singleWindowGapsOut = 24,

        -- window styling
        windowOpacity = 0.95,
        windowRounding = 15,
        windowBorderSize = 2,
        activeWindowBorderColor = "rgba(" .. scheme.primary .. "e6)",
        inactiveWindowBorderColor = "rgba(" .. scheme.onSurfaceVariant .. "11)",

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
        kbWindowGroupCycleNext = "ALT + Tab",
        kbWindowGroupCyclePrev = "SHIFT + ALT + Tab",
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

        -- apps
        kbTerminal = "SUPER + Return",
        kbBrowser = "SUPER + W",
        kbLauncher = "SUPER + space",
        kbScreenshot = "SUPER + SHIFT + S",

        -- misc
        kbSession = "CTRL + ALT + Delete",
    }
  '';

  hyprSrc = lib.cleanSourceWith {
    src = ./.;
    filter = path: type:
      let
        name = baseNameOf path;
      in
        !(name == "default.nix");
  };

  hyprConfig = pkgs.runCommand "nesw-hyprland-config" { } ''
    mkdir -p $out/scheme
    cp -r ${hyprSrc}/. $out/
    cat > $out/variables.lua <<'EOF'
${variablesLua}
EOF
    cat > $out/scheme/default.lua <<'EOF'
${schemeLua}
EOF
    cp $out/scheme/default.lua $out/scheme/current.lua
  '';
in
{
  config = {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 20;
    };

    gtk = {
      enable = true;
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
        size = 20;
      };
    };

    wayland.windowManager.hyprland = {
      enable = true;
      package = null;
      portalPackage = null;
    };

    xdg.configFile.hypr = {
      source = hyprConfig;
      recursive = true;
      force = true;
    };

    # autostart deps (see config/execs.lua)
    home.packages = with pkgs; [
      wl-clipboard # wl-paste
      cliphist # clipboard history
      trash-cli # trash-empty
      glib # gsettings
    ];

    # polkit auth agent (hyprland has no DE to autostart one)
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      Unit = {
        Description = "polkit-gnome-authentication-agent-1";
        WantedBy = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # night light (uses system geoclue2 for location)
    services.gammastep = {
      enable = true;
      provider = "geoclue2";
      temperature = {
        day = 5500;
        night = 3700;
      };
    };
  };
}
