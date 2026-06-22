import QtQuick
import qs.icons

Item {
    id: root

    property int iconSize: 26

    implicitWidth: iconSize
    implicitHeight: iconSize

    BluetoothIcon {
        glyph: "off"
        size: root.iconSize
        anchors.centerIn: parent
    }
}
