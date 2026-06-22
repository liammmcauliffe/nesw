pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property string glyph: "off"
    property int size: 26

    width: size
    height: size

    readonly property bool isSearching: root.glyph === "searching"
    property bool blinkFrame: false

    readonly property url source: {
        if (root.glyph === "connected")
            return Qt.resolvedUrl("assets/bluetooth-connected.svg")
        if (root.glyph === "off")
            return Qt.resolvedUrl("assets/bluetooth-off.svg")
        return Qt.resolvedUrl("assets/bluetooth-on.svg")
    }

    Timer {
        running: root.isSearching
        repeat: true
        interval: 260
        onTriggered: root.blinkFrame = !root.blinkFrame
        onRunningChanged: {
            if (!running)
                root.blinkFrame = false
        }
    }

    SvgIcon {
        anchors.fill: parent
        size: root.size
        source: root.source
        opacity: root.isSearching ? (root.blinkFrame ? 0 : 1) : 1
    }
}
