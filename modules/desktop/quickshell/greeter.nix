# qs -c nesw-greeter
{
    pkgs,
    quickshell,
    hyprland,
    userName,
}: let
    qsPkg = quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
    hyprlandPkg = hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

    sessionFile = pkgs.writeText "Session.qml" ''
        pragma Singleton

        import QtQuick

        QtObject {
            readonly property string sessionCommand: "${hyprlandPkg}/bin/start-hyprland"
            readonly property string defaultUser: ${builtins.toJSON userName}
        }
    '';

    greeterCommon = pkgs.runCommand "nesw-greeter-common" {} ''
        cp -r ${./config/common}/. $out/
        cp ${sessionFile} $out/Session.qml
    '';

    greeterDir = pkgs.linkFarm "nesw-greeter" [
        {name = "shell.qml"; path = ./greeter/shell.qml;}
        {name = "GreeterScreen.qml"; path = ./greeter/GreeterScreen.qml;}
        {name = "GreeterAuth.qml"; path = ./greeter/GreeterAuth.qml;}
        {name = "GreeterClock.qml"; path = ./greeter/GreeterClock.qml;}
        {name = "PasswdDisplayName.qml"; path = ./greeter/PasswdDisplayName.qml;}
        {name = "common"; path = greeterCommon;}
        {name = "icons"; path = ./config/icons;}
        {name = "status"; path = ./config/status;}
    ];

    quickshellDir = pkgs.linkFarm "quickshell" [
        {name = "nesw"; path = ./config;}
        {name = "nesw-greeter"; path = greeterDir;}
    ];

    greeterConfig = pkgs.linkFarm "nesw-greeter-xdg-config" [
        {name = "quickshell"; path = quickshellDir;}
    ];
in
    pkgs.writeShellScriptBin "nesw-greeter" ''
        export XDG_CONFIG_HOME=${greeterConfig}
        exec ${pkgs.cage}/bin/cage -s -- ${qsPkg}/bin/qs -c nesw-greeter
    ''
