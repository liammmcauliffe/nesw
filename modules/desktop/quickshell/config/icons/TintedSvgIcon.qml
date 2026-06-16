pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window
import Quickshell.Io

// White-on-transparent SVG in, any color out - tints by rewriting the SVG, no GPU shader.
Item {
    id: root

    property int size: 24
    property url source
    property color color: "white"

    width: size
    height: size

    readonly property real drawn: root.size * IconConstants.artScale
    readonly property int renderPx: Math.max(1, Math.round(root.drawn * Screen.devicePixelRatio))

    FileView {
        id: svgFile
        path: root.source
    }

    function colorHex(c) {
        const toByte = v => {
            const n = Math.round(Math.max(0, Math.min(1, v)) * 255)
            const h = n.toString(16)
            return h.length === 1 ? "0" + h : h
        }
        return "#" + toByte(c.r) + toByte(c.g) + toByte(c.b)
    }

    function tintSvg(text, strokeColor) {
        if (!text)
            return ""
        const hex = colorHex(strokeColor)
        return text
            .replace(/#FFFFFF/gi, hex)
            .replace(/#FFF\b/gi, hex)
            .replace(/stroke:\s*white/gi, "stroke:" + hex)
            .replace(/fill:\s*white/gi, "fill:" + hex)
    }

    readonly property string tintedSvg: root.tintSvg(svgFile.text(), root.color)

    readonly property url tintedSource: {
        if (!root.tintedSvg)
            return ""
        return "data:image/svg+xml;charset=utf-8," + encodeURIComponent(root.tintedSvg)
    }

    Image {
        anchors.centerIn: parent
        width: root.drawn
        height: root.drawn
        source: root.tintedSource
        sourceSize: Qt.size(root.renderPx, root.renderPx)
        fillMode: Image.PreserveAspectFit
        antialiasing: true
        smooth: true
    }
}
