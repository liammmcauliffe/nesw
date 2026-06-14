pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

// bootstrap icons battery glyphs (16x16), shell in shellColor and fill in color
Item {
    id: root

    // "empty" | "low" | "medium" | "high" | "full" | "charging"
    property string glyph: "full"
    property bool saver: false
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 20

    width: size
    height: size

    readonly property color fillColor: root.saver ? "#ffd600" : root.color
    readonly property bool isCharging: root.glyph === "charging"

    readonly property string shellPath:
        "M2 4a2 2 0 0 0-2 2v4a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2"
        + "zm10 1a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1H2a1 1 0 0 1-1-1V6a1 1 0 0 1 1-1"
        + "zm4 3a1.5 1.5 0 0 1-1.5 1.5v-3A1.5 1.5 0 0 1 16 8"

    readonly property string emptyShellPath:
        "M0 6a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v4a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2"
        + "zm2-1a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1"
        + "zm14 3a1.5 1.5 0 0 1-1.5 1.5v-3A1.5 1.5 0 0 1 16 8"

    readonly property var juicePaths: ({
        low:    "M2 6h2v4H2z",
        medium: "M2 6h5v4H2z",
        high:   "M2 6h8v4H2z",
        full:   "M2 6h10v4H2z"
    })

    readonly property string juicePath: root.juicePaths[root.glyph] ?? ""

    readonly property string lightningPath:
        "M9.585 2.568a.5.5 0 0 1 .226.58L8.677 6.832h1.99a.5.5 0 0 1 .364.843l-5.334 5.667"
        + "a.5.5 0 0 1-.842-.49L5.99 9.167H4a.5.5 0 0 1-.364-.843l5.333-5.667a.5.5 0 0 1 .616-.09z"

    readonly property string chargingShellA:
        "M2 4h4.332l-.94 1H2a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1h2.38l-.308 1H2a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2"

    readonly property string chargingShellB:
        "M2 6h2.45L2.908 7.639A1.5 1.5 0 0 0 3.313 10H2"
        + "m8.595-2-.308 1H12a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1H9.276l-.942 1H12a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2z"

    readonly property string chargingShellC:
        "M12 10h-1.783l1.542-1.639q.146-.156.241-.34"
        + "m0-3.354V6h-.646a1.5 1.5 0 0 1 .646.646"
        + "M16 8a1.5 1.5 0 0 1-1.5 1.5v-3A1.5 1.5 0 0 1 16 8"

    readonly property string chargingFill:
        "M2 6h2.45L2.908 7.639A1.5 1.5 0 0 0 3.313 10H2z"

    Shape {
        width: 16
        height: 16
        anchors.centerIn: parent
        scale: root.size / 16
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer
        visible: !root.isCharging

        ShapePath {
            fillColor: root.shellColor
            strokeWidth: 0
            PathSvg { path: root.glyph === "empty" ? root.emptyShellPath : root.shellPath }
        }
    }

    Shape {
        width: 16
        height: 16
        anchors.centerIn: parent
        scale: root.size / 16
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer
        visible: root.isCharging

        ShapePath {
            fillColor: root.shellColor
            strokeWidth: 0
            PathSvg { path: root.chargingShellA }
        }

        ShapePath {
            fillColor: root.shellColor
            strokeWidth: 0
            PathSvg { path: root.chargingShellB }
        }

        ShapePath {
            fillColor: root.shellColor
            strokeWidth: 0
            PathSvg { path: root.chargingShellC }
        }
    }

    Shape {
        width: 16
        height: 16
        anchors.centerIn: parent
        scale: root.size / 16
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer
        visible: root.juicePath.length > 0

        ShapePath {
            fillColor: root.fillColor
            strokeWidth: 0
            PathSvg { path: root.juicePath }
        }
    }

    Shape {
        width: 16
        height: 16
        anchors.centerIn: parent
        scale: root.size / 16
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer
        visible: root.isCharging

        ShapePath {
            fillColor: root.fillColor
            strokeWidth: 0
            PathSvg { path: root.chargingFill }
        }

        ShapePath {
            fillColor: root.fillColor
            strokeWidth: 0
            PathSvg { path: root.lightningPath }
        }
    }
}
