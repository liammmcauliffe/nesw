pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // "empty" | "low" | "medium" | "high" | "full"
    property string glyph: "full"
    property bool saver: false
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 20

    width: size
    height: size

    // inset so the terminal nub isn't clipped at the edges
    readonly property real glyphScale: size / 288

    readonly property string shellPath: "M200,56H32A24,24,0,0,0,8,80v96a24,24,0,0,0,24,24H200a24,24,0,0,0,24-24V80A24,24,0,0,0,200,56Zm8,120a8,8,0,0,1-8,8H32a8,8,0,0,1-8-8V80a8,8,0,0,1,8-8H200a8,8,0,0,1,8,8Zm48-80v64a8,8,0,0,1-16,0V96a8,8,0,0,1,16,0Z"

    readonly property var juicePaths: ({
        low:    "M72,96v64a8,8,0,0,1-8,8H48a8,8,0,0,1-8-8V96a8,8,0,0,1,8-8H64A8,8,0,0,1,72,96",
        medium: "M112,96v64a8,8,0,0,1-8,8H48a8,8,0,0,1-8-8V96a8,8,0,0,1,8-8h56A8,8,0,0,1,112,96",
        high:   "M152,96v64a8,8,0,0,1-8,8H48a8,8,0,0,1-8-8V96a8,8,0,0,1,8-8h96A8,8,0,0,1,152,96",
        full:   "M192,96v64a8,8,0,0,1-8,8H48a8,8,0,0,1-8-8V96a8,8,0,0,1,8-8H184A8,8,0,0,1,192,96"
    })

    readonly property string juicePath: root.juicePaths[root.glyph] ?? ""

    Shape {
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
            PathSvg { path: root.shellPath }
        }
    }

    Shape {
        width: 256
        height: 256
        x: (root.width - width * root.glyphScale) / 2
        y: (root.height - height * root.glyphScale) / 2
        scale: root.glyphScale
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer
        visible: root.juicePath.length > 0

        ShapePath {
            fillColor: root.saver ? "#ffd600" : root.color
            strokeWidth: 0
            PathSvg { path: root.juicePath }
        }
    }
}
