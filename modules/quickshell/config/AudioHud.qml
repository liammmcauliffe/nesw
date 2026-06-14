pragma ComponentBehavior: Bound

import QtQuick
import "icons"

Item {
    id: root

    property bool expanded: false
    property bool audioMode: false
    property real volume: 0
    property bool muted: false

    signal requestSetVolume(real fraction)
    signal requestBumpVolume(real delta)

    readonly property alias dragContainsMouse: audioDrag.containsMouse

    visible: opacity > 0
    opacity: root.expanded && root.audioMode ? 1 : 0
    Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    Item {
        id: volMinHit
        width: volIconMin.size + 8
        height: parent.height
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter

        VolumeIcon {
            id: volIconMin
            glyph: "none"
            size: 20
            anchors.centerIn: parent
        }

        TapHandler {
            enabled: root.audioMode
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onTapped: root.requestBumpVolume(-Constants.volumeStep)
        }
    }

    Item {
        id: volMaxHit
        width: volIconMax.size + 8
        height: parent.height
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        VolumeIcon {
            id: volIconMax
            glyph: "high"
            size: 20
            anchors.centerIn: parent
        }

        TapHandler {
            enabled: root.audioMode
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onTapped: root.requestBumpVolume(Constants.volumeStep)
        }
    }

    Item {
        id: track
        height: 20
        anchors.left: volMinHit.right
        anchors.leftMargin: 12
        anchors.right: volMaxHit.left
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter

        // animate the level, not the pixel width: while the notch expands
        // track.width keeps changing, so binding the fill to level * width
        // lets it stretch in lockstep instead of chasing a width animation
        // toward a target that is still moving
        property real level: Math.max(0, Math.min(1, root.volume))
        Behavior on level {
            NumberAnimation { duration: 90; easing.type: Easing.OutCubic }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            height: 6
            radius: height / 2
            color: Colors.palette.m3onSurfaceVariant
            opacity: 0.3
        }

        Rectangle {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            height: 6
            radius: height / 2
            width: track.level * track.width
            color: Colors.palette.m3primary
            opacity: root.muted ? 0.4 : 1
        }

        MouseArea {
            id: audioDrag
            anchors.fill: parent
            hoverEnabled: true
            preventStealing: true
            onPressed: mouse => root.requestSetVolume(mouse.x / track.width)
            onPositionChanged: mouse => {
                if (audioDrag.pressed)
                    root.requestSetVolume(mouse.x / track.width)
            }
        }
    }
}
