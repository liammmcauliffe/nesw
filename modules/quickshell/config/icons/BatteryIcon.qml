pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property string glyph: "full"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 20

    width: size
    height: size

    readonly property bool isCharging: root.glyph === "charging"
    readonly property real s: root.size / 16

    readonly property string normalShell:
        "M0 6a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2v4a2 2 0 0 1-2 2H2a2 2 0 0 1-2-2" +
        "zm2-1a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1h10a1 1 0 0 0 1-1V6a1 1 0 0 0-1-1" +
        "zm14 3a1.5 1.5 0 0 1-1.5 1.5v-3A1.5 1.5 0 0 1 16 8"

    readonly property string levelFill: {
        if (root.glyph === "low")    return "M2 6h2v4H2z"
        if (root.glyph === "medium") return "M2 6h5v4H2z"
        if (root.glyph === "high")   return "M2 6h8v4H2z"
        if (root.glyph === "full")   return "M2 6h10v4H2z"
        return ""
    }

    readonly property string chargingShell:
        "M2 4h4.332l-.94 1H2a1 1 0 0 0-1 1v4a1 1 0 0 0 1 1h2.38l-.308 1" +
        "H2a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2 " +
        "M10.595 4L10.287 5H12a1 1 0 0 1 1 1v4a1 1 0 0 1-1 1H9.276l-.942 1" +
        "H12a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2z " +
        "M12 10h-1.783l1.542-1.639q.146-.156.241-.34z " +
        "M12 6.646V6h-.646a1.5 1.5 0 0 1 .646.646 " +
        "M16 8a1.5 1.5 0 0 1-1.5 1.5v-3A1.5 1.5 0 0 1 16 8"

    readonly property string chargingAccent:
        "M9.585 2.568a.5.5 0 0 1 .226.58L8.677 6.832h1.99a.5.5 0 0 1 .364.843" +
        "l-5.334 5.667a.5.5 0 0 1-.842-.49L5.99 9.167H4a.5.5 0 0 1-.364-.843" +
        "l5.333-5.667a.5.5 0 0 1 .616-.09z " +
        "M2 6h2.45L2.908 7.639A1.5 1.5 0 0 0 3.313 10H2z"

    readonly property string shellPath: root.isCharging ? root.chargingShell : root.normalShell
    readonly property string accentPath: root.isCharging ? root.chargingAccent : root.levelFill

    Shape {
        x: 0; y: 0; width: 16; height: 16
        transform: Scale { xScale: root.s; yScale: root.s }
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.shellColor
            strokeWidth: 0
            fillRule: root.isCharging ? ShapePath.WindingFill : ShapePath.OddEvenFill
            PathSvg { path: root.shellPath }
        }
    }

    Shape {
        x: 0; y: 0; width: 16; height: 16
        transform: Scale { xScale: root.s; yScale: root.s }
        preferredRendererType: Shape.CurveRenderer
        opacity: root.accentPath.length > 0 ? 1 : 0

        ShapePath {
            fillColor: root.color
            strokeWidth: 0
            PathSvg { path: root.accentPath }
        }
    }
}
