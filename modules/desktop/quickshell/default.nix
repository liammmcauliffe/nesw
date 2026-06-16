/*
  Quickshell Desktop UI Module

  Installs Quickshell and deploys the shell UI (top bar, notch, clock, launcher).
  Generates Fonts.qml from nesw.theme so the shell matches the system UI font.

  Exposes: (none)
  Depends: modules/themes; flake input quickshell; modules/desktop/hyprland (autostart)
*/
{ config, lib, pkgs, quickshell, ... }:
let
  font = config.nesw.theme.fonts.sansSerif;

  fontsQml = ''
    pragma Singleton

    import QtQuick
    import Quickshell

    Singleton {
        id: root

        // generated from nesw.theme.fonts.sansSerif
        readonly property string family: "${font}"

        readonly property int sizeNotch: 18

        // Medium (500) is the baseline UI weight, not Regular
        readonly property int weightBaseline: Font.Medium
        readonly property int weightSemiBold: Font.DemiBold
        readonly property int weightBold: Font.Bold
    }
  '';

  quickshellSrc = lib.cleanSourceWith {
    src = ./config;
    filter = _path: type:
      type != "regular" || baseNameOf _path != "Fonts.qml";
  };
in
{
  home.packages = [
    quickshell.packages.${pkgs.system}.default
  ];

  xdg.configFile = {
    "quickshell/Fonts.qml".text = fontsQml;
    quickshell = {
      source = quickshellSrc;
      recursive = true;
    };
  };
}
