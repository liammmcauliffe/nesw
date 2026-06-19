pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property string glyph: "high"
    property int size: 20

    width: size
    height: size

    readonly property string level: {
        if (root.glyph === "off" || root.glyph === "none")
            return "none"
        if (root.glyph === "medium")
            return "med"
        if (root.glyph === "max")
            return "high"
        return root.glyph
    }

    SvgIcon {
        anchors.fill: parent
        size: root.size
        source: Qt.resolvedUrl(`assets/volume-${root.level}.svg`)
    }
}
