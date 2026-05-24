{ config, pkgs, ... }:
{
  home.stateVersion = "24.11";

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = ",preferred,auto,1";
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
      };
      decoration = {
        rounding = 10;
      };
      bind = [
        "SUPER, Return, exec, ghostty"
        "SUPER, Q, killactive"
      ];
    };
  };
}
