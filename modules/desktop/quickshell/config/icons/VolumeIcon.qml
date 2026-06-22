pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property string glyph: "max"
    property int size: 20

    width: size
    height: size

    readonly property string assetGlyph: root.glyph === "none" ? "none" : root.glyph

    SvgIcon {
        anchors.fill: parent
        size: root.size
        source: Qt.resolvedUrl(`assets/volume-${root.assetGlyph}.svg`)
    }
}
