pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    // "off" | "on" | "connected"
    property string glyph: "off"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 26

    width: size
    height: size

    SvgIcon {
        anchors.fill: parent
        size: root.size
        source: Qt.resolvedUrl(`assets/bluetooth-${root.glyph}.svg`)
    }
}
