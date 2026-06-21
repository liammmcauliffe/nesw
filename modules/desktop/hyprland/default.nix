{
    lib,
    pkgs,
    ...
}: let
    hyprSrc = lib.cleanSourceWith {
        src = ./.;
        filter = path: type:
            let name = baseNameOf path;
            in !(name == "default.nix");
    };
in {
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
            source = hyprSrc;
            recursive = true;
            force = true;
        };

        # autostart deps
        home.packages = with pkgs; [
            wl-clipboard
            cliphist
            trash-cli
            glib
            dbus
            polkit_gnome
        ];

        # night light
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
