pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // "off" | "on" | "connected"
    property string glyph: "off"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 26

    width: size
    height: size

    readonly property color activeColor: root.color
    readonly property color inactiveColor: root.shellColor
    readonly property real dotSize: 11.11

    IconArt {
        anchors.fill: parent

        Shape {
            width: IconConstants.viewBox
            height: IconConstants.viewBox
            preferredRendererType: Shape.GeometryRenderer
            antialiasing: true

            ShapePath {
                fillColor: root.glyph === "off" ? root.inactiveColor : root.activeColor
                strokeWidth: 0
                PathSvg {
                    path: "M103.89,46.67l26.67,20l-26.67,20v-3.33V46.67 M103.89,113.33l26.67,20l-26.67,20v-36.67V113.33 M97.23,25 c-2.53,0-5.04,1.15-6.67,3.33c-1.08,1.44-1.67,3.2-1.67,5v50L57.78,60c-1.5-1.12-3.25-1.66-4.99-1.66c-2.54,0-5.04,1.15-6.68,3.34 c-2.76,3.68-2.01,8.9,1.67,11.66L83.33,100l-35.56,26.67c-3.68,2.76-4.43,7.98-1.67,11.67c1.64,2.19,4.14,3.34,6.68,3.34 c1.74,0,3.49-0.54,4.99-1.66c0,0,0.01,0,0.01-0.01l31.11-23.33v50c0,4.6,3.73,8.33,8.33,8.33c1.8,0,3.56-0.58,5-1.67L146.67,140 c3.68-2.76,4.43-7.98,1.67-11.67c-0.47-0.63-1.03-1.19-1.67-1.67L111.11,100l35.56-26.67c3.68-2.76,4.43-7.98,1.67-11.67 c-0.47-0.63-1.03-1.19-1.67-1.67l-44.44-33.33C100.72,25.54,98.97,25,97.23,25L97.23,25z"
                }
            }
        }

        Rectangle {
            visible: root.glyph !== "off"
            x: 47.22 - root.dotSize / 2
            y: IconConstants.viewBox * 0.5 - root.dotSize / 2
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.glyph === "connected" ? root.activeColor : root.inactiveColor
        }

        Rectangle {
            visible: root.glyph !== "off"
            x: 152.78 - root.dotSize / 2
            y: IconConstants.viewBox * 0.5 - root.dotSize / 2
            width: root.dotSize
            height: root.dotSize
            radius: root.dotSize / 2
            color: root.glyph === "connected" ? root.activeColor : root.inactiveColor
        }
    }
}
