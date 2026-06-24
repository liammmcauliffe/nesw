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

    greeterDir = pkgs.runCommand "nesw-greeter-config" {} ''
        cp -r ${./greeter}/. $out/
        ln -s ${./config/icons} $out/icons
        ln -s ${./config/status} $out/status
        mkdir -p $out/common
        cp -r ${./config/common}/. $out/common/
        cp ${sessionFile} $out/common/Session.qml
    '';

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
