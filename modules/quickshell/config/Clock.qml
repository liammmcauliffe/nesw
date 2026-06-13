import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.right: true

    implicitWidth: label.implicitWidth + sideMargin * 2
    implicitHeight: notchHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-clock"

    // matches the center notch's reserved strip
    readonly property int notchHeight: 40
    readonly property int borderWidth: 6

    // keeps the text clear of the border's rounded corner
    readonly property int sideMargin: 24

    // fully click-through
    mask: Region {}

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Text {
        id: label
        text: Qt.formatDateTime(clock.date, "ddd MMM d  h:mm AP")
        // flat white default until the scheme drives the top bar foreground
        color: "white"
        font.family: Fonts.family
        font.pixelSize: 16
        font.weight: Fonts.weightSemiBold

        anchors.right: parent.right
        anchors.rightMargin: root.sideMargin

        // centered in the strip-to-notch-bottom band, like a menu bar clock
        y: root.borderWidth + (root.notchHeight - root.borderWidth - height) / 2
    }
}
