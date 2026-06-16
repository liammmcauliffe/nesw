/*
  Ghostty Terminal Module

  Installs Ghostty and writes ~/.config/ghostty/config (no extension).
  Fonts come from nesw.theme; CSD is off so Hyprland owns window chrome.

  Exposes: (none)
  Depends: modules/themes; nesw.desktop.hyprland.terminal (default app name)
*/
{ config, pkgs, ... }:
let
  fonts = config.nesw.theme.fonts;
in
{
  home.packages = with pkgs; [
    ghostty
  ];

  xdg.configFile."ghostty/config".text = ''
    # font — primary face + Nerd Font fallback for Starship / eza icons
    font-family = "${fonts.monospace}"
    font-family = "${fonts.monospaceNerd}"
    font-size = 14

    # window — no GTK CSD; Hyprland handles borders, gaps, and rounding
    window-decoration = false
    gtk-tabs = false
    window-vsync = true
    window-padding-x = 10
    window-padding-y = 10
    window-padding-balance = true
    window-save-state = always

    # appearance
    theme = "Vague"
    window-colorspace = display-p3
    background-opacity = 0.8
    background-blur = 90
    cursor-style = block
    adjust-cell-height = 35%

    # input
    copy-on-select = clipboard
    mouse-hide-while-typing = true
    mouse-scroll-multiplier = 2

    # shell
    shell-integration = fish
  '';
}
