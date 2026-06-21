import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import qs.common

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: barHeight + cornerRadius
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-topbar"

    readonly property int barHeight: 40
    readonly property int borderWidth: Constants.borderWidth
    readonly property int cornerRadius: 23
    readonly property color barColor: "#59000000"

    mask: Region {}

    Shape {
        id: shape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.barColor
            strokeWidth: 0

            startX: 0
            startY: 0

            PathLine { x: shape.width; y: 0 }

            PathLine {
                x: shape.width
                y: root.barHeight + root.cornerRadius
            }

            PathLine {
                x: shape.width - root.borderWidth
                y: root.barHeight + root.cornerRadius
            }

            PathArc {
                x: shape.width - root.borderWidth - root.cornerRadius
                y: root.barHeight
                radiusX: root.cornerRadius
                radiusY: root.cornerRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.borderWidth + root.cornerRadius
                y: root.barHeight
            }

            PathArc {
                x: root.borderWidth
                y: root.barHeight + root.cornerRadius
                radiusX: root.cornerRadius
                radiusY: root.cornerRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: 0
                y: root.barHeight + root.cornerRadius
            }

            PathLine { x: 0; y: 0 }
        }
    }
}
