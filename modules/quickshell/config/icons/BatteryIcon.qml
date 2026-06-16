pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property string glyph: "full"
    property color color: "white"
    property color shellColor: "#a1a1aa"
    property color saverColor: "#FFD600"
    property color chargingColor: "#22C55E"
    property bool powerSaving: false
    property int size: 20

    width: size
    height: size

    readonly property color activeColor: root.color
    readonly property color inactiveColor: root.shellColor
    readonly property bool isCharging: root.glyph === "charging"

    readonly property color juiceColor: {
        if (root.isCharging)
            return root.chargingColor
        if (root.powerSaving)
            return root.saverColor
        return root.activeColor
    }

    readonly property string juicePath: {
        if (root.glyph === "low")
            return "M17.61,119.7V80.3c0-7.18,5.82-13,13-13h9.22c7.18,0,13,5.82,13,13v39.41c0,7.18-5.82,13-13,13h-9.22C23.43,132.7,17.61,126.88,17.61,119.7z"
        if (root.glyph === "medium")
            return "M16.71,119.7V80.3c0-7.18,5.82-13,13-13h44.44c7.18,0,13,5.82,13,13v39.41c0,7.18-5.82,13-13,13H29.71C22.53,132.7,16.71,126.88,16.71,119.7z"
        if (root.glyph === "high" || root.glyph === "charging")
            return "M17.61,119.7V80.3c0-7.18,5.82-13,13-13h79.66c7.18,0,13,5.82,13,13v39.41c0,7.18-5.82,13-13,13H30.61C23.43,132.7,17.61,126.88,17.61,119.7z"
        if (root.glyph === "full")
            return "M17.61,119.7V80.3c0-7.18,5.82-13,13-13h114.88c7.18,0,13,5.82,13,13v39.41c0,7.18-5.82,13-13,13H30.61C23.43,132.7,17.61,126.88,17.61,119.7z"
        return ""
    }

    IconArt {
        anchors.fill: parent

        Shape {
            width: IconConstants.viewBox
            height: IconConstants.viewBox
            preferredRendererType: Shape.GeometryRenderer
            antialiasing: true

            ShapePath {
                fillColor: root.inactiveColor
                strokeWidth: 0
                PathSvg {
                    path: "M150.94,59.69c8.36,0,15.16,6.8,15.16,15.16v50.31c0,8.36-6.8,15.16-15.16,15.16H25.16c-8.36,0-15.16-6.8-15.16-15.16V74.84c0-8.36,6.8-15.16,15.16-15.16H150.94 M150.94,49.69H25.16C11.26,49.69,0,60.95,0,74.84v50.31c0,13.89,11.26,25.16,25.16,25.16h125.79c13.89,0,25.16-11.26,25.16-25.16V74.84C176.1,60.95,164.84,49.69,150.94,49.69L150.94,49.69z"
                }
            }

            ShapePath {
                fillColor: root.inactiveColor
                strokeWidth: 0
                PathSvg {
                    path: "M200,100c0,10.42-8.45,18.87-18.87,18.87V81.13C191.55,81.13,200,89.58,200,100"
                }
            }
        }

        Shape {
            width: IconConstants.viewBox
            height: IconConstants.viewBox
            preferredRendererType: Shape.GeometryRenderer
            antialiasing: true
            opacity: root.juicePath.length > 0 ? 1 : 0

            ShapePath {
                fillColor: root.juiceColor
                strokeWidth: 0
                PathSvg { path: root.juicePath }
            }
        }
    }
}
