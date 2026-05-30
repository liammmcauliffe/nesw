import QtQuick
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

    // Frame style
    readonly property int thickness: 4
    readonly property int rounding: 23

    // Fully click-through
    mask: Region {}

    // Screen frame
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: root.rounding
        border.width: root.thickness
        border.color: "black"
    }
}
