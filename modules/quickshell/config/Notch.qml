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

    implicitHeight: notchHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Auto
    WlrLayershell.namespace: "nesw-notch"

    // Notch size
    readonly property int notchWidth: 200
    readonly property int notchHeight: 34
    readonly property int bottomRadius: 14
    readonly property int topRadius: 14

    // Click-through except the notch
    mask: Region {
        x: (root.width - shape.width) / 2
        y: 0
        width: shape.width
        height: shape.height
    }

    // Notch shape
    Shape {
        id: shape
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.notchWidth + root.topRadius * 2
        height: root.notchHeight

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: "black"
            strokeWidth: 0

            startX: 0
            startY: 0

            // Top-left rounds out into the screen edge
            PathArc {
                x: root.topRadius; y: root.topRadius
                radiusX: root.topRadius; radiusY: root.topRadius
                direction: PathArc.Clockwise
            }

            // Left side
            PathLine { x: root.topRadius; y: root.notchHeight - root.bottomRadius }

            // Bottom-left
            PathArc {
                x: root.topRadius + root.bottomRadius; y: root.notchHeight
                radiusX: root.bottomRadius; radiusY: root.bottomRadius
                direction: PathArc.Counterclockwise
            }

            // Bottom edge
            PathLine { x: shape.width - root.topRadius - root.bottomRadius; y: root.notchHeight }

            // Bottom-right
            PathArc {
                x: shape.width - root.topRadius; y: root.notchHeight - root.bottomRadius
                radiusX: root.bottomRadius; radiusY: root.bottomRadius
                direction: PathArc.Counterclockwise
            }

            // Right side
            PathLine { x: shape.width - root.topRadius; y: root.topRadius }

            // Top-right rounds out into the screen edge
            PathArc {
                x: shape.width; y: 0
                radiusX: root.topRadius; radiusY: root.topRadius
                direction: PathArc.Clockwise
            }

            // Top edge
            PathLine { x: 0; y: 0 }
        }
    }
}
