import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland

// Translucent dark band across the top of the screen, blurred by hyprland
// (see the nesw-topbar layer rule). Sits beneath the notch and clock so the
// solid black notch stands out and white text stays readable on any wallpaper.
// The bottom corners curl down the screen edges with concave fillets that hug
// the windows' rounded top corners, mirroring how the border hugs them below.
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

    // Matches the notch height so the band covers the full notch/clock span
    readonly property int barHeight: 40
    // Matches the border's corner rounding so the fillets hug the same way
    readonly property int cornerRadius: 23
    readonly property color barColor: "#59000000"

    // Fully click-through
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

            // Down the right screen edge past the bar bottom
            PathLine {
                x: shape.width
                y: root.barHeight + root.cornerRadius
            }

            // Concave fillet curling back up to the bar bottom
            PathArc {
                x: shape.width - root.cornerRadius
                y: root.barHeight
                radiusX: root.cornerRadius
                radiusY: root.cornerRadius
                direction: PathArc.Counterclockwise
            }

            // Across the bar bottom
            PathLine {
                x: root.cornerRadius
                y: root.barHeight
            }

            // Concave fillet curling down the left screen edge
            PathArc {
                x: 0
                y: root.barHeight + root.cornerRadius
                radiusX: root.cornerRadius
                radiusY: root.cornerRadius
                direction: PathArc.Counterclockwise
            }

            PathLine { x: 0; y: 0 }
        }
    }
}
