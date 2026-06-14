pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    // "high" | "medium" | "low" | "none" | "connecting"
    property string glyph: "high"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property int size: 32

    width: size
    height: size

    readonly property real glyphScale: size / 34
    readonly property real viewBoxY: 5 // viewBox origin is 0 -5
    readonly property bool isConnecting: root.glyph === "connecting"

    property int connectFrame: 0

    // fontisto wifi — outer arc omitted (same 2-bar + dot layout as before)
    readonly property string dotPath: "M16.807,27.2a1.6,1.6,0,1,1,0,3.2a1.6,1.6,0,1,1,0,-3.2"
    readonly property string barInner: "m16.815 24 5.475-5.415-.87-.713c-1.188-.938-2.708-1.505-4.359-1.505-.089 0-.178.002-.266.005h.013c-.02 0-.043 0-.066 0-1.712 0-3.293.563-4.567 1.515l.02-.014-.862.713.795.787 3.96 3.915z"
    readonly property string barMid: "m27.405 12.03c-2.783-2.531-6.498-4.08-10.575-4.08-.002 0-.005 0-.007 0h-.667l-.007.015c-3.847.159-7.313 1.674-9.958 4.076l.013-.012-.787.713 3.893 3.855.72-.63c1.791-1.606 4.171-2.587 6.78-2.587s4.989.982 6.79 2.596l-.01-.008.72.63 3.893-3.854z"

    function barFill(layer) {
        const active = root.color
        const grey = root.shellColor

        if (root.isConnecting) {
            // dot → inner → mid → inner → dot
            if (layer === "dot")
                return root.connectFrame === 0 || root.connectFrame === 4 ? active : grey
            if (layer === "inner")
                return root.connectFrame === 1 || root.connectFrame === 3 ? active : grey
            if (layer === "mid")
                return root.connectFrame === 2 ? active : grey
            return grey
        }

        if (root.glyph === "none")
            return grey

        if (root.glyph === "low") {
            if (layer === "dot")
                return active
            return grey
        }

        if (root.glyph === "medium") {
            if (layer === "mid")
                return grey
            return active
        }

        // high — dot + both arcs
        return active
    }

    Timer {
        running: root.isConnecting
        repeat: true
        interval: 260
        onTriggered: root.connectFrame = (root.connectFrame + 1) % 5
    }

    onGlyphChanged: {
        if (!root.isConnecting)
            connectFrame = 0
    }

    Shape {
        width: 34
        height: 34
        x: (root.width - width * root.glyphScale) / 2
        y: (root.height - height * root.glyphScale) / 2 + root.viewBoxY * root.glyphScale
        scale: root.glyphScale
        transformOrigin: Item.TopLeft
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.barFill("mid")
            strokeWidth: 0
            PathSvg { path: root.barMid }
        }

        ShapePath {
            fillColor: root.barFill("inner")
            strokeWidth: 0
            PathSvg { path: root.barInner }
        }

        ShapePath {
            fillColor: root.barFill("dot")
            strokeWidth: 0
            PathSvg { path: root.dotPath }
        }
    }
}
