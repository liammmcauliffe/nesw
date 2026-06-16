pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property color color: "white"
    property int size: 20

    width: size
    height: size

    SvgIcon {
        anchors.fill: parent
        size: root.size
        source: Qt.resolvedUrl("assets/return-key.svg")
    }
}
