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
          gaps_in     = 5,
          gaps_out    = 10,
          border_size = 2,
        },
        decoration = {
          rounding = 10,
        },
        cursor = {
          default_monitor = "",
        },
      })

      hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
      hl.bind(mainMod .. " + C",      hl.dsp.window.close())
      hl.bind(mainMod .. " + M",      hl.dsp.exit())
    '';
  };
}
