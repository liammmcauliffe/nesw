pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // "high" | "medium" | "low" | "none" | "slash"
    property string glyph: "high"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 28

    width: size
    height: size

    readonly property real glyphScale: size / 288
    readonly property bool isSlash: root.glyph === "slash"

    // phosphor fill wifi-high, split inner → outer + dot
    readonly property string dotPath: "M144,204a16,16,0,1,1-16-16A16,16,0,0,1,144,204"
    readonly property string barInner: "M175.07,155.3a80.05,80.05,0,0,0-94.14,0,12,12,0,0,0,14.14,19.4,56,56,0,0,1,65.86,0,12,12,0,1,0,14.14-19.4Z"
    readonly property string barMid: "M207.45,119.64a128,128,0,0,0-158.9,0,12,12,0,0,0,14.9,18.81,104,104,0,0,1,129.1,0,12,12,0,0,0,14.9-18.81"
    readonly property string barOuter: "M239.61,83.91a176,176,0,0,0-223.22,0,12,12,0,1,0,15.23,18.55,152,152,0,0,1,192.76,0,12,12,0,1,0,15.23-18.55"

    readonly property var slashWifiStrokes: [
        "M71.6,66A163.53,163.53,0,0,0,24,93.19",
        "M107.78,105.76A115.46,115.46,0,0,0,56,129",
        "M154.81,157.49A68.1,68.1,0,0,0,88,165",
        "M232,93.19A163.31,163.31,0,0,0,128,56q-5.58,0-11.06.37",
        "M200,129a115.84,115.84,0,0,0-34-18.66"
    ]

    function barFill(layer) {
        const active = root.color
        const grey = root.shellColor

        if (root.glyph === "none")
            return grey

        if (root.glyph === "low") {
            if (layer === "inner" || layer === "dot")
                return active
            return grey
        }

        if (root.glyph === "medium") {
            if (layer === "outer")
                return grey
            return active
        }

        return active
    }

    // filled signal bars for high / medium / low / none
    Shape {
        visible: !root.isSlash
        width: 256
        height: 256
        x: (root.width - width * root.glyphScale) / 2
        y: (root.height - height * root.glyphScale) / 2
        scale: root.glyphScale
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.barFill("outer")
            strokeWidth: 0
            PathSvg { path: root.barOuter }
        }

        ShapePath {
            fillColor: root.barFill("mid")
            strokeWidth: 0
            PathSvg { path: root.barMid }
        }

        ShapePath {
            fillColor: root.barFill("inner")
            strokeWidth: 0
            PathSvg { path: root.barInner }
        }

        ShapePath {
            fillColor: root.barFill("dot")
            strokeWidth: 0
            PathSvg { path: root.dotPath }
        }
    }

    // slash: grey wifi strokes + dot, white diagonal slash only
    Shape {
        visible: root.isSlash
        width: 256
        height: 256
        x: (root.width - width * root.glyphScale) / 2
        y: (root.height - height * root.glyphScale) / 2
        scale: root.glyphScale
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.shellColor
            strokeWidth: 0
            PathSvg { path: "M128,188a16,16,0,1,1,0,32a16,16,0,1,1,0,-32" }
        }

        ShapePath {
            strokeColor: root.shellColor
            strokeWidth: 24
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.slashWifiStrokes[0] }
        }

        ShapePath {
            strokeColor: root.shellColor
            strokeWidth: 24
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.slashWifiStrokes[1] }
        }

        ShapePath {
            strokeColor: root.shellColor
            strokeWidth: 24
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.slashWifiStrokes[2] }
        }

        ShapePath {
            strokeColor: root.shellColor
            strokeWidth: 24
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.slashWifiStrokes[3] }
        }

        ShapePath {
            strokeColor: root.shellColor
            strokeWidth: 24
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: root.slashWifiStrokes[4] }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 24
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg { path: "M48,40L208,216" }
        }
    }
}
