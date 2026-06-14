pragma ComponentBehavior: Bound

import QtQuick

Item {
    id: root

    property real slideOffset: 0
    property bool expanded: false
    property bool audioMode: false
    property bool inSpecialWs: false
    property int indicatorWs: 1
    property int rulerMax: 1
    property var occupied: ({})

    readonly property int tickLaneHeight: 14
    readonly property int numberTickGap: 4

    Text {
        id: wsLabel
        text: root.inSpecialWs ? "S" : root.indicatorWs
        color: Colors.palette.m3primary
        font.family: Fonts.family
        font.pixelSize: Fonts.sizeNotch
        font.weight: Fonts.weightBold
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: tickLane.top
        anchors.bottomMargin: root.numberTickGap
        z: 1

        opacity: root.expanded && !root.audioMode ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }
    }

    Item {
        id: tickLane
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 1
        width: parent.width
        height: tickLaneHeight

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
                    readonly property int mainTickHeight: tick.isActive ? 12
                          : tick.isOccupied ? 11 : 8

                    width: Constants.stepPx
                    height: strip.height

                    Repeater {
                        model: [-2, -1, 1, 2, 3]

                        delegate: Rectangle {
                            required property int modelData

                            visible: !(tick.wsNumber === 1 && modelData < 0)

                            width: 1
                            height: 5
                            radius: 0.5
                            color: root.inSpecialWs ? Colors.palette.m3tertiary : Colors.palette.m3onSurfaceVariant
                            opacity: 0.3
                            anchors.bottom: parent.bottom
                            x: tick.width / 2 + modelData * (Constants.stepPx / 6) - width / 2
                        }
                    }

                    Rectangle {
                        width: 2
                        height: tick.mainTickHeight
                        radius: 1
                        color: root.inSpecialWs ? Colors.palette.m3tertiary
                             : tick.isActive ? Colors.palette.m3primary
                             : tick.isOccupied ? Colors.palette.m3onSurface
                             : Colors.palette.m3onSurfaceVariant
                        opacity: tick.isActive || tick.isOccupied ? 1 : 0.5
                        anchors.horizontalCenter: tick.horizontalCenter
                        anchors.bottom: tick.bottom

                        Behavior on height {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 180 }
                        }
                    }
                }
            }
        }
    }
}
