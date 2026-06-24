pragma ComponentBehavior: Bound

import QtQuick
import qs.common

Item {
    id: root

    property real slideOffset: 0
    property bool expanded: false
    property bool audioMode: false
    property bool inSpecialWs: false
    property int indicatorWs: 1
    property int rulerMax: 1
    property var occupied: ({})

    Row {
        id: strip
        height: parent.height
        x: root.width / 2 - Constants.stepPx / 2 + root.slideOffset

        opacity: root.expanded && !root.audioMode ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        Repeater {
            model: root.rulerMax

            delegate: Item {
                id: tick
                required property int index

                readonly property int wsNumber: index + 1
                readonly property bool isActive: wsNumber === root.indicatorWs
                readonly property bool isOccupied: root.occupied[wsNumber] === true

                width: Constants.stepPx
                height: root.height

                Repeater {
                    model: [-3, -2, -1, 1, 2, 3]

                    delegate: Rectangle {
                        required property int modelData

                        visible: !(tick.wsNumber === 1 && modelData < 0)

                        width: 1
                        height: 6
                        radius: 0.5
                        color: root.inSpecialWs ? Colors.m3tertiary : Colors.m3onSurfaceVariant
                        opacity: 0.3
                        x: tick.width / 2 + modelData * (Constants.stepPx / 6) - width / 2
                        anchors.verticalCenter: tick.verticalCenter
                    }
                }

                Rectangle {
                    width: 2
                    height: 14
                    radius: 1
                    color: root.inSpecialWs ? Colors.m3tertiary
                         : tick.isActive ? Colors.m3primary
                         : tick.isOccupied ? Colors.m3onSurface
                         : Colors.m3onSurfaceVariant
                    opacity: tick.isActive || tick.isOccupied ? 1 : 0.5
                    anchors.horizontalCenter: tick.horizontalCenter
                    anchors.verticalCenter: tick.verticalCenter

                    Behavior on color {
                        ColorAnimation { duration: 180 }
                    }
                }
            }
        }
    }

    Text {
        text: root.inSpecialWs ? "S" : root.indicatorWs
        color: Colors.m3primary
        font.family: Fonts.family
        font.pixelSize: Fonts.sizeNotch
        font.weight: Fonts.weightBold
        anchors.left: root.horizontalCenter
        anchors.leftMargin: 6
        anchors.verticalCenter: root.verticalCenter

        opacity: root.expanded && !root.audioMode ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }
}
