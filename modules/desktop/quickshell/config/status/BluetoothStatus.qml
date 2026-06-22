import QtQuick
import qs.icons

Item {
    id: root

    property int iconSize: 26

    implicitWidth: iconSize
    implicitHeight: iconSize

    readonly property var states: ["off", "on", "searching", "connected"]
    property int stateIndex: 0

    BluetoothIcon {
        glyph: root.states[root.stateIndex]
        size: root.iconSize
        anchors.centerIn: parent
    }

    TapHandler {
        onTapped: root.stateIndex = (root.stateIndex + 1) % root.states.length
    }
}
