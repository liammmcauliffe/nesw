pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property bool playing: false
    property color color: "white"
    property int size: 22

    width: size
    height: size

    readonly property string playPath:
        "M240,128a15.74,15.74,0,0,1-7.6,13.51L88.32,229.65a16,16,0,0,1-16.2.3A15.86,15.86,0,0,1,64,216.13V39.87a15.86,15.86,0,0,1,8.12-13.82,16,16,0,0,1,16.2.3L232.4,114.49A15.74,15.74,0,0,1,240,128Z"
    readonly property string pausePath:
        "M216,48H176a16,16,0,0,0-16,16V192a16,16,0,0,0,16,16h40a16,16,0,0,0,16-16V64A16,16,0,0,0,216,48ZM80,48H40A16,16,0,0,0,24,64V192a16,16,0,0,0,16,16H80a16,16,0,0,0,16-16V64A16,16,0,0,0,80,48Z"

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.color
            strokeWidth: 0
            PathSvg { path: root.playing ? root.pausePath : root.playPath }
        }

        transform: Scale {
            xScale: root.size / 256
            yScale: root.size / 256
        }
    }
}
