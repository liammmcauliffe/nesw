pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // "high" | "medium" | "low" | "none" | "connecting"
    property string glyph: "high"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 26

    width: size
    height: size

    readonly property color activeColor: root.color
    readonly property color inactiveColor: root.shellColor

    readonly property bool isConnecting: root.glyph === "connecting"
    property int connectFrame: 0

    readonly property bool outerActive: !root.isConnecting
        ? root.glyph === "high"
        : root.connectFrame === 2
    readonly property bool midActive: !root.isConnecting
        ? (root.glyph === "high" || root.glyph === "medium")
        : (root.connectFrame === 1 || root.connectFrame === 3)
    readonly property bool innerActive: !root.isConnecting
        ? (root.glyph === "high" || root.glyph === "medium" || root.glyph === "low")
        : root.connectFrame === 0

    readonly property real unitScale: root.size / IconConstants.viewBox

    Timer {
        running: root.isConnecting
        repeat: true
        interval: 260
        onTriggered: root.connectFrame = (root.connectFrame + 1) % 4
        onRunningChanged: {
            if (!running)
                root.connectFrame = 0
        }
    }

    Item {
        anchors.fill: parent
        scale: IconConstants.artScale
        transformOrigin: Item.Center

        Shape {
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            transform: Scale {
                xScale: root.unitScale
                yScale: root.unitScale
            }

            ShapePath {
                fillColor: root.outerActive ? root.activeColor : root.inactiveColor
                strokeWidth: 0
                PathSvg {
                    path: "M27.85,90.11c1.42,1.48,3.52,1.41,4.87-0.08c17.71-19.62,41.11-29.94,67.29-29.94 c26.33,0,49.81,10.4,67.44,30.02c1.27,1.33,3.3,1.33,4.65-0.16l9.98-10.4c1.2-1.33,1.2-3.05,0.22-4.3 c-16.95-21.73-48.83-37.76-82.29-37.76S34.68,53.52,17.72,75.26c-1.05,1.25-0.98,2.97,0.22,4.3L27.85,90.11z"
                }
            }

            ShapePath {
                fillColor: root.midActive ? root.activeColor : root.inactiveColor
                strokeWidth: 0
                PathSvg {
                    path: "M57.86,121.46c1.5,1.64,3.45,1.48,4.87-0.23c8.7-10.09,22.8-17.36,37.28-17.2 c14.63-0.16,28.66,7.35,37.43,17.43c1.42,1.56,3.3,1.56,4.73-0.08l11.18-11.49c1.2-1.25,1.35-2.89,0.22-4.22 c-10.88-13.99-31.06-24.31-53.56-24.31s-42.68,10.4-53.56,24.32c-1.12,1.33-0.97,2.89,0.22,4.22L57.86,121.46z"
                }
            }

            ShapePath {
                fillColor: root.innerActive ? root.activeColor : root.inactiveColor
                strokeWidth: 0
                PathSvg {
                    path: "M100.02,162.5c1.57,0,3-0.86,5.77-3.67l17.56-17.59c1.12-1.09,1.35-2.81,0.37-4.14 c-4.73-6.33-13.58-11.8-23.7-11.8c-10.35,0-19.35,5.71-24,12.27c-0.68,1.09-0.45,2.58,0.67,3.67l17.56,17.59 C97.02,161.64,98.44,162.5,100.02,162.5"
                }
            }
        }
    }
}
