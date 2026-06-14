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
                path: "M57.08,20.28A8,8,0,0,1,64,24H192a8,8,0,0,1,0,16H72.49L200.75,122.62a8,8,0,0,1,0,10.76L72.49,216H192a8,8,0,0,1,0,16H64a8,8,0,0,1-5.23-14.1L182.56,128,58.77,38.1A8,8,0,0,1,57.08,20.28Z"
            }
        }

        transform: Scale {
            xScale: root.size / 256
            yScale: root.size / 256
        }
    }
}
