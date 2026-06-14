import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import "icons"

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.right: true

    implicitWidth: row.implicitWidth + sideMargin * 2
    implicitHeight: notchHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-clock"

    readonly property int notchHeight: 40
    readonly property int borderWidth: 6
    readonly property int sideMargin: 24

    mask: Region {}

    readonly property bool showBattery: UPower.displayDevice.ready && UPower.displayDevice.isPresent

    readonly property bool charging: showBattery
        && (UPower.displayDevice.state === UPowerDeviceState.Charging
            || UPower.displayDevice.state === UPowerDeviceState.PendingCharge)

    readonly property bool pluggedIn: showBattery && !UPower.onBattery

    readonly property real percentage: showBattery ? UPower.displayDevice.percentage : 0

    readonly property bool isLow: percentage < 0.15 && !pluggedIn

    readonly property string glyph: {
        if (percentage >= 0.90) return "full"
        if (percentage >= 0.60) return "high"
        if (percentage >= 0.30) return "medium"
        if (percentage >= 0.10) return "low"
        return "empty"
    }

    readonly property color batteryColor: {
        if (isLow)     return Colors.palette.m3error
        return "white"
    }

    readonly property color boltColor: pluggedIn ? Colors.palette.m3primary : "white"

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.rightMargin: root.sideMargin
        spacing: 14
        y: root.borderWidth + (root.notchHeight - root.borderWidth - height) / 2

        BatteryIcon {
            visible: root.showBattery
            glyph: root.glyph
            charging: root.charging
            color: root.batteryColor
            shellColor: Colors.palette.m3onSurfaceVariant
            boltColor: root.boltColor
            size: 32
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 300 } }
            Behavior on shellColor { ColorAnimation { duration: 300 } }
            Behavior on boltColor { ColorAnimation { duration: 300 } }
        }

        Text {
            id: label
            text: Qt.formatDateTime(clock.date, "ddd MMM d  h:mm AP")
            color: "white"
            font.family: Fonts.family
            font.pixelSize: 16
            font.weight: Fonts.weightSemiBold
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
