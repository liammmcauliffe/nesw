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
            fillColor: root.color
            strokeWidth: 0
            fillRule: ShapePath.OddEvenFill
            
            PathSvg {
                path: "M9,4 H39 A5,5 0 0 1 44,9 V39 A5,5 0 0 1 39,44 H9 A5,5 0 0 1 4,39 V9 A5,5 0 0 1 9,4 Z"
                    + " M14,13 H34 A2,2 0 0 1 36,15 V27 A2,2 0 0 1 34,29 H31 V33 A2,2 0 0 1 29,35 H19 A2,2 0 0 1 17,33 V29 H14 A2,2 0 0 1 12,27 V15 A2,2 0 0 1 14,13 Z"
            }
        }
    }
}