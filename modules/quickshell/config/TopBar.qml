import QtQuick 2.15
import QtQuick.Shapes 1.15
import Quickshell
import Quickshell.Wayland

// translucent dark band across the top of the screen, blurred by hyprland
// (see the nesw-topbar layer rule). sits beneath the notch and clock so the
// solid black notch stands out and white text stays readable on any wallpaper.
// the bottom corners curl down the screen edges with concave fillets that hug
// the windows' rounded top corners, mirroring how the border hugs them below
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

    // matches the notch height so the band covers the full notch/clock span
    readonly property int barHeight: 40
    // matches the border frame so the fillets sit on its inner edge and
    // mirror the screen's bottom corners exactly
    readonly property int borderWidth: 6
    readonly property int cornerRadius: 23
    readonly property color barColor: "#59000000"

    // fully click-through
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

            // down the right edge past the bar bottom (the border strip
            // overlays the outer 6px, so this edge stays hidden behind it)
            PathLine {
                x: shape.width
                y: root.barHeight + root.cornerRadius
            }

            PathLine {
                x: shape.width - root.borderWidth
                y: root.barHeight + root.cornerRadius
            }

            // concave fillet from the border's inner edge up to the bar bottom
            PathArc {
                x: shape.width - root.borderWidth - root.cornerRadius
                y: root.barHeight
                radiusX: root.cornerRadius
                radiusY: root.cornerRadius
                direction: PathArc.Counterclockwise
            }

            // across the bar bottom
            PathLine {
                x: root.borderWidth + root.cornerRadius
                y: root.barHeight
            }

            // concave fillet curling down to the left border's inner edge
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
