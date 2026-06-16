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
            preferredRendererType: Shape.CurveRenderer
            antialiasing: true

            ShapePath {
                fillColor: "transparent"
                strokeColor: root.color
                strokeWidth: 10
                joinStyle: ShapePath.RoundJoin
                PathSvg {
                    path: "M173.86,48.86v102.27c0,6.28-5.09,11.36-11.36,11.36h-125c-6.28,0-11.36-5.09-11.36-11.36 V48.86c0-6.28,5.09-11.36,11.36-11.36h125C168.78,37.5,173.86,42.59,173.86,48.86"
                }
            }

            ShapePath {
                fillColor: "transparent"
                strokeColor: root.color
                strokeWidth: 15
                capStyle: ShapePath.RoundCap
                joinStyle: ShapePath.RoundJoin
                PathSvg {
                    path: "M134.09,82.35v23.25 M66.64,105.6h67.45 M66.61,105.63l16.97-16.97 M83.58,122.58 l-16.97-16.96"
                }
            }
        }
    }
}
