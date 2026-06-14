pragma ComponentBehavior: Bound

import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: root

    // "high" | "medium" | "low" | "none" | "connecting"
    property string glyph: "high"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 26

    width: size
    height: size

    readonly property bool isConnecting: root.glyph === "connecting"
    property int connectFrame: 0

    readonly property string barOuter: "M5.465 25.035c.445.445 1.101.422 1.523-.023 5.532-5.883 12.844-8.977 21.024-8.977 8.226 0 15.562 3.117 21.07 9 .398.399 1.032.399 1.453-.047l3.118-3.117c.374-.398.374-.914.07-1.289-5.297-6.516-15.258-11.32-25.711-11.32S7.598 14.066 2.3 20.582c-.328.375-.305.89.07 1.29Z"
    readonly property string barMid: "M14.84 34.434c.469.492 1.078.445 1.523-.07 2.719-3.024 7.125-5.204 11.649-5.157 4.57-.047 8.953 2.203 11.695 5.227.445.468 1.031.468 1.477-.024l3.492-3.445c.375-.375.422-.867.07-1.266-3.398-4.195-9.703-7.289-16.734-7.289s-13.336 3.117-16.735 7.29c-.351.398-.304.866.07 1.265Z"
    readonly property string barInner: "M28.012 46.738c.492 0 .937-.258 1.804-1.101l5.485-5.274c.351-.328.422-.843.117-1.242-1.477-1.898-4.242-3.539-7.406-3.539-3.235 0-6.047 1.711-7.5 3.68-.211.328-.14.773.21 1.101l5.485 5.274c.867.843 1.313 1.101 1.805 1.101"

    readonly property bool _showInner: root.glyph === "high" || root.glyph === "medium" || root.glyph === "low" || (root.isConnecting && (root.connectFrame === 0 || root.connectFrame === 4))
    readonly property bool _showMid:   root.glyph === "high" || root.glyph === "medium" || (root.isConnecting && (root.connectFrame === 1 || root.connectFrame === 3))
    readonly property bool _showOuter: root.glyph === "high" || (root.isConnecting && root.connectFrame === 2)

    Timer {
        running: root.isConnecting
        repeat: true
        interval: 260
        onTriggered: root.connectFrame = (root.connectFrame + 1) % 5
        onRunningChanged: {
            if (!running)
                root.connectFrame = 0
        }
    }

    Shape {
        width: 56
        height: 56
        anchors.centerIn: parent
        scale: root.size / 56
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root._showOuter ? root.color : root.shellColor
            strokeWidth: 0
            PathSvg { path: root.barOuter }
        }

        ShapePath {
            fillColor: root._showMid ? root.color : root.shellColor
            strokeWidth: 0
            PathSvg { path: root.barMid }
        }

        ShapePath {
            fillColor: root._showInner ? root.color : root.shellColor
            strokeWidth: 0
            PathSvg { path: root.barInner }
        }
    }
}