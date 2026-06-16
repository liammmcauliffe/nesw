pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property string glyph: "full"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property color saverColor: "#FFD600"
    property color chargingColor: "#22C55E"
    property bool powerSaving: false
    property int size: 20

    width: size
    height: size

    readonly property bool isCharging: root.glyph === "charging"

    readonly property url source: {
        if (root.glyph === "empty")
            return Qt.resolvedUrl("assets/battery-empty.svg")
        if (root.isCharging)
            return Qt.resolvedUrl("assets/battery-charging.svg")
        const level = root.glyph
        if (root.powerSaving)
            return Qt.resolvedUrl(`assets/battery-${level}-saver.svg`)
        return Qt.resolvedUrl(`assets/battery-${level}.svg`)
    }

    SvgIcon {
        anchors.fill: parent
        size: root.size
        source: root.source
    }
}
