import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true

    // Window is always tall enough for the expanded state; the rest is
    // transparent + click-through thanks to the mask below.
    implicitHeight: expandedHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-notch"

    // ---- State ----
    property bool expanded: false

    // Collapsed / expanded dimensions (tune these for your display)
    readonly property int collapsedWidth: 200
    readonly property int collapsedHeight: 34
    readonly property int expandedWidth: 420
    readonly property int expandedHeight: 160
    readonly property int cornerRadius: 14

    // Animated current dims — single source of truth for the mask + the shape,
    // so the interactive region always matches what's drawn.
    property real notchWidth: expanded ? expandedWidth : collapsedWidth
    property real notchHeight: expanded ? expandedHeight : collapsedHeight

    Behavior on notchWidth {
        NumberAnimation { duration: 360; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
    }
    Behavior on notchHeight {
        NumberAnimation { duration: 360; easing.type: Easing.OutBack; easing.overshoot: 1.1 }
    }

    // Only the notch intercepts the mouse; transparent areas pass clicks through.
    mask: Region {
        x: (root.width - root.notchWidth) / 2
        y: 0
        width: root.notchWidth
        height: root.notchHeight
    }

    Rectangle {
        id: notch
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.notchWidth
        height: root.notchHeight
        color: "black"
        clip: true

        // Flush with the screen top, rounded on the bottom only.
        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: root.cornerRadius
        bottomRightRadius: root.cornerRadius

        // Expand on hover, collapse when the pointer leaves.
        HoverHandler {
            id: hover
            onHoveredChanged: root.expanded = hovered
        }

        // Content fades in only when expanded.
        Item {
            anchors.fill: parent
            anchors.margins: 16
            opacity: root.expanded ? 1 : 0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 180 } }

            Text {
                id: clock
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: 30
                font.bold: true
                text: Qt.formatDateTime(new Date(), "h:mm AP")
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clock.text = Qt.formatDateTime(new Date(), "h:mm AP")
    }
}
