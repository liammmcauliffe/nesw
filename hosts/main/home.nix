{ config, pkgs, ... }:
{
  home.stateVersion = "26.05";

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };
  };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting ""
    '';
  };

  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      local terminal = "ghostty"
      local mainMod  = "SUPER"

      hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
      hl.env("XCURSOR_SIZE",  "24")

      hl.monitor({
        output   = "",
        mode     = "preferred",
        position = "auto",
        scale    = "auto",
      })

      hl.config({
        general = {
          gaps_in     = 2,
          gaps_out    = 4,
          border_size = 4,
        },
        decoration = {
          rounding = 4,
        },
        cursor = {
          default_monitor = "",
        },
        misc = {
          background_color = "rgb(000000)",
          disable_hyprland_logo = true,
          disable_splash_rendering = true,
        },
      })

      hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
      hl.bind(mainMod .. " + C",      hl.dsp.window.close())
      hl.bind(mainMod .. " + M",      hl.dsp.exit())
    '';
  };
}
