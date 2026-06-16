{ pkgs, zen-browser, ... }:
{
  home.packages = [
    zen-browser.packages.${pkgs.system}.default
  ];
}
