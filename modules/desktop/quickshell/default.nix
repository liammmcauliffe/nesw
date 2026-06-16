{ pkgs, quickshell, ... }:
{
  home.packages = [
    quickshell.packages.${pkgs.system}.default
  ];

  xdg.configFile."quickshell".source = ./config;
}
