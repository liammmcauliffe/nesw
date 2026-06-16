pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property color color: "white"
    property int size: 20

    width: size
    height: size

    TintedSvgIcon {
        anchors.fill: parent
        size: root.size
        color: root.color
        source: Qt.resolvedUrl("assets/search.svg")
    }
}
