pragma Singleton

import QtQuick
import Quickshell

QtObject {
    id: root

    readonly property var shellScreen: {
        const list = Quickshell.screens
        for (let i = 0; i < list.length; i++) {
            if (list[i].name === "eDP-1")
                return list[i]
        }
        return list.length > 0 ? list[0] : null
    }

    // notch geometry
    readonly property int minWidth: 300
    readonly property int maxWidth: 360
    readonly property int notchHeight: 40
    readonly property int notchRadius: 15
    readonly property int borderWidth: 4
    readonly property int notchPadding: 16
    readonly property int hitHeight: 120
    readonly property int launcherWidth: 784
    readonly property real launcherTopMarginRatio: 0.17
    readonly property color notchColor: "black"

    // workspace ruler
    readonly property int stepPx: 46
    readonly property int rulerBuffer: 5
    readonly property int frameInset: 4

    // audio hud
    readonly property real volumeStep: 0.05
}
