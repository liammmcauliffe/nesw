/*
  Zen Browser Module

  Installs Zen Browser from the zen-browser flake input with Wayland and
  VA-API environment variables for native Hyprland rendering and HW video decode.

  Exposes: (none)
  Depends: flake input zen-browser; nesw.desktop.hyprland.browser (default: zen-beta)
*/
{ pkgs, zen-browser, ... }:
{
  home.packages = [
    zen-browser.packages.${pkgs.system}.default
  ];

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };
}
