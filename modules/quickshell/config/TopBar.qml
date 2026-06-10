import QtQuick
import Quickshell
import Quickshell.Wayland

// Translucent dark band across the top of the screen, blurred by hyprland
// (see the nesw-topbar layer rule). Sits beneath the notch and clock so the
// solid black notch stands out and white text stays readable on any wallpaper.
PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: barHeight
    color: "#59000000"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-topbar"

    // Matches the notch height so the band covers the full notch/clock span
    readonly property int barHeight: 40

    // Fully click-through
    mask: Region {}
}
