{ config, pkgs, ... }:
{
  home.stateVersion = "26.05";

  wayland.windowManager.hyprland = {
    enable = true;
    extraLuaConfig = ''
      local terminal = "ghostty"
      local mainMod  = "SUPER"

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
      })

      hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
      hl.bind(mainMod .. " + C",      hl.dsp.window.close())
      hl.bind(mainMod .. " + M",      hl.dsp.exit())
    '';
  };
}
