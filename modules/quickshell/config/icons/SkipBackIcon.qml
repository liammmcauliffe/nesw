pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color color: "white"
    property int size: 20

    width: size
    height: size

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeWidth: 0
            PathSvg {
                path: "M198.92,235.72A8,8,0,0,1,192,232H64a8,8,0,0,1,0-16H183.51L55.25,133.38a8,8,0,0,1,0-10.76L183.51,40H64a8,8,0,0,1,0-16H192a8,8,0,0,1,5.23,14.1L73.44,128,197.23,217.9A8,8,0,0,1,198.92,235.72Z"
            }
        }

        transform: Scale {
            xScale: root.size / 256
            yScale: root.size / 256
        }
    }
}
