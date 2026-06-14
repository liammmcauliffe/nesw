import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower
import "icons"

PanelWindow {
    id: root

    screen: Quickshell.screens[0]
    anchors.top: true
    anchors.left: true

    implicitWidth: row.implicitWidth + sideMargin * 2
    implicitHeight: notchHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-battery"

    readonly property int notchHeight: 40
    readonly property int borderWidth: 6
    readonly property int sideMargin: 24

    mask: Region {}

    readonly property var bat: UPower.displayDevice

    readonly property bool charging: bat
        ? bat.state === UPowerDeviceState.Charging
          || bat.state === UPowerDeviceState.FullyCharged
        : false

    readonly property real percentage: bat ? bat.percentage : 100

    readonly property bool isLow: percentage < 15 && !charging

    readonly property string glyph: {
        if (percentage >= 90) return "full"
        if (percentage >= 60) return "high"
        if (percentage >= 30) return "medium"
        if (percentage >= 10) return "low"
        return "empty"
    }

    // white normally, m3error when low, m3primary when charging/full
    readonly property color itemColor: {
        if (charging)  return Colors.palette.m3primary
        if (isLow)     return Colors.palette.m3error
        return "white"
    }

    Row {
        id: row
        anchors.left: parent.left
        anchors.leftMargin: root.sideMargin
        spacing: 6
        y: root.borderWidth + (root.notchHeight - root.borderWidth - height) / 2

        BatteryIcon {
            glyph: root.glyph
            charging: root.charging
            color: root.itemColor
            size: 18
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 300 } }
        }

        Text {
            text: Math.round(root.percentage) + "%"
            color: root.itemColor
            font.family: Fonts.family
            font.pixelSize: 16
            font.weight: Fonts.weightSemiBold
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 300 } }
        }
    }
}
