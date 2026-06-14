pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color color: "white"
    property int size: 28

    width: size
    height: size

    Shape {
        width: 48
        height: 48
        anchors.centerIn: parent
        scale: root.size / 48
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: 4
            fillColor: root.color
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap

            PathSvg { 
                path: "M 9 6 H 39 A 3 3 0 0 1 42 9 V 39 A 3 3 0 0 1 39 42 H 9 A 3 3 0 0 1 6 39 V 9 A 3 3 0 0 1 9 6 Z" 
            }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: "transparent"
            strokeWidth: 0
            fillRule: ShapePath.EvenOddFill 

            PathSvg { 
                path: "M14,15 h20 v12 H14 Z M19,27 h10 v6 H19 Z" 
            }
        }

        ShapePath {
            strokeColor: root.color
            strokeWidth: 4
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathSvg { 
                path: "M21,15 v4 M27,15 v4" 
            }
        }
    }
}