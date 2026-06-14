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

    readonly property var bat: UPower.displayDevice

    readonly property bool showBattery: bat && bat.ready && bat.isLaptopBattery

    readonly property bool charging: showBattery
        ? bat.state === UPowerDeviceState.Charging
          || bat.state === UPowerDeviceState.FullyCharged
        : false

    // UPower reports 0–1, not 0–100
    readonly property real percentage: showBattery ? bat.percentage : 0

    readonly property int percentageText: Math.round(percentage * 100)

    readonly property bool isLow: percentage < 0.15 && !charging

    readonly property string glyph: {
        if (percentage >= 0.90) return "full"
        if (percentage >= 0.60) return "high"
        if (percentage >= 0.30) return "medium"
        if (percentage >= 0.10) return "low"
        return "empty"
    }

    readonly property color batteryColor: {
        if (charging) return Colors.palette.m3primary
        if (isLow)    return Colors.palette.m3error
        return "white"
    }

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

        Row {
            visible: root.showBattery
            spacing: 6

            BatteryIcon {
                glyph: root.glyph
                charging: root.charging
                color: root.batteryColor
                size: 16
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 300 } }
            }

            Text {
                text: root.percentageText + "%"
                color: root.batteryColor
                font.family: Fonts.family
                font.pixelSize: 16
                font.weight: Fonts.weightSemiBold
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 300 } }
            }
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
