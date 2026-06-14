pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

// phosphor fill-weight magnifying-glass glyph
Item {
    id: root

    property color color: "white"
    property int size: 20

    width: size
    height: size

    readonly property string path: "M229.66,218.34l-50.07-50.06a88.11,88.11,0,1,0-11.31,11.31l50.06,50.07a8,8,0,0,0,11.32-11.32ZM40,112a72,72,0,1,1,72,72A72.08,72.08,0,0,1,40,112Z"

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
