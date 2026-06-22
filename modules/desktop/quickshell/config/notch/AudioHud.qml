pragma ComponentBehavior: Bound

import QtQuick
import qs.common
import qs.icons

Item {
    id: root

    property bool expanded: false
    property bool audioMode: false
    property real volume: 0
    property bool muted: false

    signal requestSetVolume(real fraction)
    signal requestBumpVolume(real delta)

    readonly property alias dragContainsMouse: audioDrag.containsMouse

    readonly property int barHeight: 6
    readonly property int barRadius: barHeight / 2
    readonly property color barFg: Colors.m3primary
    readonly property color barBg: Colors.m3onSurfaceVariant
    readonly property color barMuted: Colors.m3onSurfaceVariant

    readonly property url currentIcon: {
        if (root.muted)
            return Qt.resolvedUrl("../icons/assets/volume-muted.svg")
        if (root.volume <= 0.001)
            return Qt.resolvedUrl("../icons/assets/volume-none.svg")
        if (root.volume < 0.33)
            return Qt.resolvedUrl("../icons/assets/volume-low.svg")
        if (root.volume < 0.66)
            return Qt.resolvedUrl("../icons/assets/volume-medium.svg")
        return Qt.resolvedUrl("../icons/assets/volume-max.svg")
    }

    visible: opacity > 0
    opacity: root.expanded && root.audioMode ? 1 : 0
    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Item {
        id: layout
        anchors.centerIn: parent
        width: parent.width
        height: Math.max(icon.implicitHeight, root.barHeight)

        SvgIcon {
            id: icon
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            source: root.currentIcon
            size: 26
            iconColor: root.muted ? root.barMuted : root.barFg
        }

        Rectangle {
            id: barBgRect
            anchors.left: icon.right
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: root.barHeight
            radius: root.barRadius
            color: root.barBg
            opacity: 0.3
        }

        Rectangle {
            id: barFillRect
            anchors.left: barBgRect.left
            anchors.top: barBgRect.top
            width: barBgRect.width * Math.max(0, Math.min(1, root.volume))
            height: root.barHeight
            radius: root.barRadius
            color: root.muted ? root.barMuted : root.barFg
            clip: true
        }

        Item {
            anchors.fill: barBgRect
            anchors.topMargin: -12
            anchors.bottomMargin: -12
            anchors.leftMargin: -6
            anchors.rightMargin: -6

            MouseArea {
                id: audioDrag
                anchors.fill: parent
                hoverEnabled: true
                preventStealing: true
                onPressed: mouse => root.requestSetVolume(mouse.x / barBgRect.width)
                onPositionChanged: mouse => {
                    if (audioDrag.pressed)
                        root.requestSetVolume(mouse.x / barBgRect.width)
                }
            }
        }

        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                let delta = event.angleDelta.y
                if (delta === 0)
                    delta = event.pixelDelta.y
                if (delta > 0)
                    root.requestBumpVolume(Constants.volumeStep)
                else if (delta < 0)
                    root.requestBumpVolume(-Constants.volumeStep)
            }
        }
    }
}
