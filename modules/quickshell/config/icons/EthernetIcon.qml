pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color color: "white"
    property int size: 28

    width: size
    height: size

    readonly property real glyphScale: size / 48

    Shape {
        width: 48
        height: 48
        x: (root.width - width * root.glyphScale) / 2
        y: (root.height - height * root.glyphScale) / 2
        scale: root.glyphScale
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            joinStyle: ShapePath.RoundJoin
            PathSvg {
                path: "M9,6 H39 A3,3 0 0 1 42,9 V39 A3,3 0 0 1 39,42 H9 A3,3 0 0 1 6,39 V9 A3,3 0 0 1 9,6 Z"
            }
        }

        ShapePath {
            fillColor: root.color
            strokeWidth: 0
            PathSvg {
                path: "M14,15 H34 V27 H14 Z M19,27 H29 V33 H19 Z"
            }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap
            PathSvg { path: "M21,15 V19 M27,15 V19" }
        }
    }
}
