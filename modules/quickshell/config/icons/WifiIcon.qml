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

    readonly property bool isConnecting: root.glyph === "connecting"
    property int connectFrame: 0

    readonly property string barOuter: "M16.807 0h-.045C10.572 0 4.942 2.4.752 6.319l.013-.012L0 7.02l3.862 3.826.72-.66c3.201-2.952 7.494-4.763 12.21-4.763s9.009 1.81 12.222 4.774l-.012-.011.72.66 3.862-3.826-.765-.713A23.3 23.3 0 0 0 16.845 0h-.041.002z"
    readonly property string barMid: "M27.405 12.03A15.67 15.67 0 0 0 16.83 7.95h-.674l-.007.015a15.72 15.72 0 0 0-9.958 4.076l.013-.012-.787.713 3.893 3.855.72-.63c1.791-1.606 4.171-2.587 6.78-2.587s4.989.982 6.79 2.596l-.01-.008.72.63 3.893-3.854z"
    readonly property string barInner: "m16.815 24 5.475-5.415-.87-.713a7.02 7.02 0 0 0-4.625-1.5h.013-.066a7.6 7.6 0 0 0-4.567 1.515l.02-.014-.862.713.795.787 3.96 3.915z"

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
        width: 34
        height: 34
        anchors.centerIn: parent
        scale: root.size / 34
        transformOrigin: Item.Center
        preferredRendererType: Shape.CurveRenderer

        transform: Translate { x: 0; y: 5 }

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
