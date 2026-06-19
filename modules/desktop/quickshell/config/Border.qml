import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true
    anchors.bottom: true

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-border"

    readonly property int thickness: Constants.borderWidth
    readonly property int rounding: 23
    readonly property color frameColor: "black"

    mask: Region {}

    Shape {
        id: frame
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.frameColor
            strokeWidth: 0
            fillRule: ShapePath.OddEvenFill

            startX: 0
            startY: 0
            PathLine { x: frame.width; y: 0 }
            PathLine { x: frame.width; y: frame.height }
            PathLine { x: 0; y: frame.height }
            PathLine { x: 0; y: 0 }

            PathMove { x: root.thickness; y: root.thickness }
            PathLine { x: frame.width - root.thickness; y: root.thickness }
            PathLine { x: frame.width - root.thickness; y: frame.height - root.thickness - root.rounding }
            PathArc { x: frame.width - root.thickness - root.rounding; y: frame.height - root.thickness; radiusX: root.rounding; radiusY: root.rounding }
            PathLine { x: root.thickness + root.rounding; y: frame.height - root.thickness }
            PathArc { x: root.thickness; y: frame.height - root.thickness - root.rounding; radiusX: root.rounding; radiusY: root.rounding }
            PathLine { x: root.thickness; y: root.thickness }
        }
    }
}
