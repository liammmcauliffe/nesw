/*
  Zen Browser Module

  Installs Zen Browser from the zen-browser flake input.

  Exposes: (none)
  Depends: flake input zen-browser; nesw.desktop.hyprland.browser (default app name)
*/
{ pkgs, zen-browser, ... }:
{
  home.packages = [
    zen-browser.packages.${pkgs.system}.default
  ];
}
