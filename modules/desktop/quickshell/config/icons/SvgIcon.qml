pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window

Item {
    id: root

    // ponytail: 1.15 scales glyph art within the hit box; was IconConstants.artScale singleton
    readonly property real artScale: 1.15
    property int size: 24
    property url source

    width: size
    height: size

    readonly property real drawn: root.size * root.artScale
    readonly property int renderPx: Math.max(1, Math.round(root.drawn * Screen.devicePixelRatio))

    Image {
        anchors.centerIn: parent
        width: root.drawn
        height: root.drawn
        source: root.source
        sourceSize: Qt.size(root.renderPx, root.renderPx)
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        smooth: true
    }
}
