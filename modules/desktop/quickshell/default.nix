# Fonts.qml generated below; systemd user service (qs -c nesw)
{ config, lib, pkgs, quickshell, ... }:
let
  cfg = config.programs.quickshell.nesw;
  qsPkg = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;

  fontsQml = ''
    pragma Singleton

    import QtQuick
    import Quickshell

    Singleton {
        id: root

        readonly property string family: "DM Sans"

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
  imports = [ ./generator.nix ];

  options.programs.quickshell.nesw.enable =
    lib.mkEnableOption "NESW Quickshell shell (systemd user service)";

  config = lib.mkIf cfg.enable {
    home.packages = [ qsPkg ];

    xdg.configFile = {
      "quickshell/nesw/Fonts.qml".text = fontsQml;
      "quickshell/nesw" = {
        source = quickshellSrc;
        recursive = true;
      };
    };

    home.file.".local/state/nesw/.keep".text = "";

    systemd.user.services.quickshell = {
      Unit = {
        Description = "NESW Quickshell Shell";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${qsPkg}/bin/qs -c nesw";
        Restart = "on-failure";
        RestartSec = 5;
        Environment = [
          "QT_QPA_PLATFORM=wayland"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION=1"
        ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
