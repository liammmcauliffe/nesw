pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    // "high" | "medium" | "low" | "none" | "connecting"
    property string glyph: "high"
    property int size: 26

    width: size
    height: size

    readonly property bool isConnecting: root.glyph === "connecting"
    property int connectFrame: 0

    readonly property url source: {
        if (root.isConnecting)
            return Qt.resolvedUrl(`assets/wifi-connect-${root.connectFrame}.svg`)
        if (root.glyph === "none")
            return Qt.resolvedUrl("assets/wifi-none.svg")
        return Qt.resolvedUrl(`assets/wifi-${root.glyph}.svg`)
    }

    Timer {
        running: root.isConnecting
        repeat: true
        interval: 260
        onTriggered: root.connectFrame = (root.connectFrame + 1) % 4
        onRunningChanged: {
            if (!running)
                root.connectFrame = 0
        }
    }

    SvgIcon {
        anchors.fill: parent
        size: root.size
        source: root.source
    }
}
