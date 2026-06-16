pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color color: "white"
    property int size: 20

    width: size
    height: size

    IconArt {
        anchors.fill: parent

        Shape {
            width: IconConstants.viewBox
            height: IconConstants.viewBox
            preferredRendererType: Shape.GeometryRenderer
            antialiasing: true

            ShapePath {
                fillColor: "transparent"
                strokeColor: root.color
                strokeWidth: 15
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                PathSvg {
                    path: "M43.75,87.5c0,24.16,19.59,43.75,43.75,43.75s43.75-19.59,43.75-43.75 S111.66,43.75,87.5,43.75S43.75,63.34,43.75,87.5 M156.25,156.25l-37.5-37.5"
                }
            }
        }
    }
}
