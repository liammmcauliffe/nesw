pragma Singleton

import QtQuick 2.15
import Quickshell

Singleton {
    id: root

    // notch geometry
    readonly property int minWidth: 300
    readonly property int maxWidth: 360
    readonly property int notchHeight: 40
    readonly property int notchRadius: 15
    readonly property int borderWidth: 6
    readonly property int notchPadding: 16
    readonly property int hitHeight: 120
    readonly property color notchColor: "black"

    // workspace ruler
    readonly property int stepPx: 46
    readonly property int rulerBuffer: 5
    readonly property int frameInset: 4

    // audio hud
    readonly property real volumeStep: 0.05
}
