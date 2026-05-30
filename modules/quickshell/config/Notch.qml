import QtQuick
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

    // Click-through except the notch
    mask: Region {
        x: (root.width - root.notchWidth) / 2
        y: 0
        width: root.notchWidth
        height: root.notchHeight
    }

    // Notch shape
    Rectangle {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.notchWidth
        height: root.notchHeight
        color: "black"

        topLeftRadius: 0
        topRightRadius: 0
        bottomLeftRadius: 14
        bottomRightRadius: 14
    }
}
