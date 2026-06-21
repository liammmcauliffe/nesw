import QtQuick
import Quickshell
import Quickshell.Wayland
import common

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.right: true

    implicitWidth: row.implicitWidth + sideMargin * 2
    implicitHeight: barHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-status-bar"

    readonly property int barHeight: 40
    readonly property int borderWidth: Constants.borderWidth
    readonly property int sideMargin: 24
    readonly property int iconSize: 26
    readonly property int clockFontSize: 18

    Item {
        id: hitMask
        anchors.fill: parent
        visible: false
    }

    mask: Region {
        item: hitMask
    }

    Row {
        id: row
        anchors.right: parent.right
        anchors.rightMargin: root.sideMargin
        spacing: 28
        y: root.borderWidth + (root.barHeight - root.borderWidth - height) / 2

        NetworkStatus {
            iconSize: root.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        BatteryStatus {
            iconSize: root.iconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        ClockDisplay {
            fontSize: root.clockFontSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
