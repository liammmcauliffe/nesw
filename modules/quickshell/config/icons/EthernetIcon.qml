pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property color color: "white"
    property int size: 26

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
                strokeWidth: 15
                joinStyle: ShapePath.MiterJoin
                miterLimit: 10
                PathSvg {
                    path: "M131.25,125h25c3.45,0,6.25,2.8,6.25,6.25v25c0,3.45-2.8,6.25-6.25,6.25h-25c-3.45,0-6.25-2.8-6.25-6.25v-25 C125,127.8,127.8,125,131.25,125z M43.75,125h25c3.45,0,6.25,2.8,6.25,6.25v25c0,3.45-2.8,6.25-6.25,6.25h-25c-3.45,0-6.25-2.8-6.25-6.25v-25 C37.5,127.8,40.3,125,43.75,125z M87.5,37.5h25c3.45,0,6.25,2.8,6.25,6.25v25c0,3.45-2.8,6.25-6.25,6.25h-25c-3.45,0-6.25-2.8-6.25-6.25v-25 C81.25,40.3,84.05,37.5,87.5,37.5z M56.25,125v-18.75c0-3.45,2.8-6.25,6.25-6.25h75c3.45,0,6.25,2.8,6.25,6.25V125 M100,100v-25"
                }
            }
        }
    }
}
