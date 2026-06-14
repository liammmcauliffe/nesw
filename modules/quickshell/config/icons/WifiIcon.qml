pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // "high" | "medium" | "low" | "none"
    property string glyph: "high"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 28

    width: size
    height: size

    readonly property real glyphScale: size / 288

    // phosphor fill wifi-high — inner + mid arcs + dot (no outer arc)
    readonly property string dotPath: "M144,204a16,16,0,1,1-16-16A16,16,0,0,1,144,204"
    readonly property string barInner: "M175.07,155.3a80.05,80.05,0,0,0-94.14,0,12,12,0,0,0,14.14,19.4,56,56,0,0,1,65.86,0,12,12,0,1,0,14.14-19.4Z"
    readonly property string barMid: "M207.45,119.64a128,128,0,0,0-158.9,0,12,12,0,0,0,14.9,18.81,104,104,0,0,1,129.1,0,12,12,0,0,0,14.9-18.81"

    function barFill(layer) {
        const active = root.color
        const grey = root.shellColor

        if (root.glyph === "none")
            return grey

        if (root.glyph === "low") {
            if (layer === "dot")
                return active
            return grey
        }

        if (root.glyph === "medium") {
            if (layer === "mid")
                return grey
            return active
        }

        // high — dot + both arcs
        return active
    }

    Shape {
        width: 256
        height: 256
        x: (root.width - width * root.glyphScale) / 2
        y: (root.height - height * root.glyphScale) / 2
        scale: root.glyphScale
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

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
}
