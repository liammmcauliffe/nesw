pragma ComponentBehavior: Bound

import QtQuick

// Renders child shapes at the SVG viewBox size, then scales down once with MSAA.
Item {
    id: root

    default property alias contents: canvas.data

    readonly property real displayScale: width / IconConstants.viewBox * IconConstants.artScale

    Item {
        id: canvas
        anchors.centerIn: parent
        width: IconConstants.viewBox
        height: IconConstants.viewBox
        scale: root.displayScale
        transformOrigin: Item.Center

        layer.enabled: true
        layer.smooth: true
        layer.samples: 4
    }
}
