pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

// phosphor fill-weight x-circle glyph
Item {
    id: root

    property color color: "white"
    property int size: 20

    width: size
    height: size

    readonly property string path: "M165.66,101.66,139.31,128l26.35,26.34a8,8,0,0,1-11.32,11.32L128,139.31l-26.34,26.35a8,8,0,0,1-11.32-11.32L116.69,128,90.34,101.66a8,8,0,0,1,11.32-11.32L128,116.69l26.34-26.35a8,8,0,0,1,11.32,11.32ZM232,128A104,104,0,1,1,128,24,104.11,104.11,0,0,1,232,128Zm-16,0a88,88,0,1,0-88,88A88.1,88.1,0,0,0,216,128Z"

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeWidth: 0
            PathSvg { path: root.path }
        }

        transform: Scale {
            xScale: root.size / 256
            yScale: root.size / 256
        }
    }
}
