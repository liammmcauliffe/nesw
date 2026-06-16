pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window

// Renders children at the SVG viewBox size, then scales to the icon slot once.
Item {
    id: root

    default property alias contents: canvas.data

    // Snap to physical pixels so strokes and fills don't sit on fractional texels.
    readonly property real displayScale: {
        if (width <= 0)
            return 0
        const dpr = Screen.devicePixelRatio > 0 ? Screen.devicePixelRatio : 1
        const logicalPx = width * IconConstants.artScale
        const snappedLogical = Math.round(logicalPx * dpr) / dpr
        return snappedLogical / IconConstants.viewBox
    }

    Item {
        id: canvas
        anchors.centerIn: parent
        width: IconConstants.viewBox
        height: IconConstants.viewBox
        scale: root.displayScale
        transformOrigin: Item.Center
    }
}
