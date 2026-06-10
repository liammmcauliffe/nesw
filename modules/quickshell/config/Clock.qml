import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true

    implicitWidth: edgeOffset + shape.width
    implicitHeight: notchHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-clock"

    // Matches the center notch geometry
    readonly property int notchHeight: 40
    readonly property int notchRadius: 15
    readonly property int borderWidth: 6
    readonly property int notchPadding: 16
    readonly property color notchColor: "black"

    // Clears the border's rounded corner at the top-left
    readonly property int edgeOffset: 24

    // Sized to content plus padding
    readonly property real notchWidth: label.implicitWidth + notchPadding * 2

    // Fully click-through
    mask: Region {}

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Shape {
        id: shape
        x: root.edgeOffset
        y: 0

        width: root.notchWidth + root.notchRadius * 2
        height: root.notchHeight
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.notchColor
            strokeWidth: 0

            startX: 0
            startY: 0

            PathLine {
                x: 0
                y: root.borderWidth
            }

            PathArc {
                x: root.notchRadius
                y: root.borderWidth + root.notchRadius
                radiusX: root.notchRadius
                radiusY: root.notchRadius
                direction: PathArc.Clockwise
            }

            PathLine {
                x: root.notchRadius
                y: root.notchHeight - root.notchRadius
            }

            PathArc {
                x: root.notchRadius * 2
                y: root.notchHeight
                radiusX: root.notchRadius
                radiusY: root.notchRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: shape.width - root.notchRadius * 2
                y: root.notchHeight
            }

            PathArc {
                x: shape.width - root.notchRadius
                y: root.notchHeight - root.notchRadius
                radiusX: root.notchRadius
                radiusY: root.notchRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: shape.width - root.notchRadius
                y: root.borderWidth + root.notchRadius
            }

            PathArc {
                x: shape.width
                y: root.borderWidth
                radiusX: root.notchRadius
                radiusY: root.notchRadius
                direction: PathArc.Clockwise
            }

            PathLine { x: shape.width; y: 0 }
            PathLine { x: 0; y: 0 }
        }
    }

    Text {
        id: label
        text: Qt.formatDateTime(clock.date, "ddd MMM d h:mmAP")
        color: Colors.palette.m3onSurface
        font.family: Fonts.family
        font.pixelSize: 14
        font.weight: Fonts.weightBold

        anchors.horizontalCenter: shape.horizontalCenter
        y: root.borderWidth + (root.notchHeight - root.borderWidth - height) / 2
    }
}
