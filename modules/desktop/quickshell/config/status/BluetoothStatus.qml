import QtQuick
import qs.icons

Item {
    id: root

    property int iconSize: 26

    implicitWidth: iconSize
    implicitHeight: iconSize
    width: iconSize
    height: iconSize

    readonly property var states: ["off", "on", "searching", "connected"]
    property int stateIndex: 0

    BluetoothIcon {
        glyph: root.states[root.stateIndex]
        size: root.iconSize
        anchors.centerIn: parent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.stateIndex = (root.stateIndex + 1) % root.states.length
    }
}
