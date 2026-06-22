pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property string glyph: "off"
    property int size: 26

    width: size
    height: size

    readonly property bool isSearching: root.glyph === "searching"
    readonly property bool hasDots: root.glyph === "on"
            || root.glyph === "searching"
            || root.glyph === "connected"

    property bool blinkFrame: false

    readonly property real artScale: 1.15
    readonly property real drawn: root.size * root.artScale
    readonly property real symbolOffset: (root.size - root.drawn) / 2
    readonly property real dotRadius: 10 / 200 * root.drawn
    readonly property color zincColor: "#A1A1AA"
    readonly property color whiteColor: "#FFFFFF"

    readonly property color leftDotColor: {
        if (root.glyph === "connected")
            return root.whiteColor
        if (root.isSearching)
            return root.blinkFrame ? root.whiteColor : root.zincColor
        return root.zincColor
    }

    readonly property color rightDotColor: {
        if (root.glyph === "connected")
            return root.whiteColor
        if (root.isSearching)
            return root.blinkFrame ? root.zincColor : root.whiteColor
        return root.zincColor
    }

    readonly property url source: root.glyph === "off"
            ? Qt.resolvedUrl("assets/bluetooth-off.svg")
            : Qt.resolvedUrl("assets/bluetooth-symbol.svg")

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
    }

    Rectangle {
        visible: root.hasDots
        width: root.dotRadius * 2
        height: root.dotRadius * 2
        radius: root.dotRadius
        color: root.leftDotColor
        x: root.symbolOffset + (47.22 / 200) * root.drawn - root.dotRadius
        y: root.symbolOffset + (100 / 200) * root.drawn - root.dotRadius
    }

    Rectangle {
        visible: root.hasDots
        width: root.dotRadius * 2
        height: root.dotRadius * 2
        radius: root.dotRadius
        color: root.rightDotColor
        x: root.symbolOffset + (152.78 / 200) * root.drawn - root.dotRadius
        y: root.symbolOffset + (100 / 200) * root.drawn - root.dotRadius
    }
}
