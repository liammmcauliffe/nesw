pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property string glyph: "full"
    property bool powerSaving: false
    property bool charging: false
    property int size: 20

    width: size
    height: size

    readonly property url source: {
        if (root.glyph === "empty")
            return Qt.resolvedUrl("assets/battery-empty.svg")
        const level = root.glyph
        if (root.powerSaving)
            return Qt.resolvedUrl(`assets/battery-${level}-saver.svg`)
        return Qt.resolvedUrl(`assets/battery-${level}.svg`)
    }

    SvgIcon {
        anchors.fill: parent
        size: root.size
        source: root.source
        visible: !root.charging
    }

    SvgIcon {
        anchors.fill: parent
        size: root.size
        source: root.source
        iconColor: "#22C55E"
        visible: root.charging
    }
}
