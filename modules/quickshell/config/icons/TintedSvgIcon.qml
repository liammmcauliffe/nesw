pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property int size: 24
    property url source
    property color color: "white"

    width: size
    height: size

    readonly property real drawn: root.size * IconConstants.artScale
    readonly property int renderPx: Math.max(1, Math.round(root.drawn * Screen.devicePixelRatio))

    Image {
        id: src

        anchors.centerIn: parent
        width: root.drawn
        height: root.drawn
        source: root.source
        sourceSize: Qt.size(root.renderPx, root.renderPx)
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        smooth: true
        visible: false
    }

    ColorOverlay {
        width: src.width
        height: src.height
        anchors.centerIn: parent
        source: src
        color: root.color
    }
}
