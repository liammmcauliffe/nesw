pragma ComponentBehavior: Bound

import QtQuick

// Renders children at the SVG viewBox size, then scales to the icon slot once.
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
    }
}
