pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Window

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

    ShaderEffectSource {
        id: effectSource

        anchors.centerIn: parent
        width: src.width
        height: src.height
        sourceItem: src
        live: true
        hideSource: true
    }

    ShaderEffect {
        anchors.centerIn: parent
        width: src.width
        height: src.height

        property variant source: effectSource
        property color tint: root.color

        fragmentShader: "
            varying highp vec2 qt_TexCoord0;
            uniform sampler2D source;
            uniform lowp vec4 tint;
            void main() {
                lowp vec4 c = texture2D(source, qt_TexCoord0);
                lowp float a = max(c.a, max(c.r, max(c.g, c.b)));
                gl_FragColor = vec4(tint.rgb, a * tint.a);
            }
        "
    }
}
