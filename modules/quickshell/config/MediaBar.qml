pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris
import "icons"

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true

    implicitHeight: Constants.notchHeight
    implicitWidth: row.implicitWidth + sideMargin * 2
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "nesw-media"

    readonly property int sideMargin: 24

    readonly property var activePlayer: {
        const players = Mpris.players.values
        if (players.length === 0)
            return null
        return players[0]
    }

    readonly property bool hasPlayer: Mpris.players.values.length > 0

    Item {
        id: content
        anchors.fill: parent
        visible: opacity > 0.01
        opacity: root.hasPlayer ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        Row {
            id: row
            anchors.left: parent.left
            anchors.leftMargin: root.sideMargin
            spacing: 16
            y: Constants.borderWidth + (Constants.notchHeight - Constants.borderWidth - height) / 2

        Item {
            width: skipBackIcon.size + 8
            height: skipBackIcon.size + 8
            anchors.verticalCenter: parent.verticalCenter

            SkipBackIcon {
                id: skipBackIcon
                color: "white"
                anchors.centerIn: parent
            }

            TapHandler {
                enabled: root.hasPlayer
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onTapped: root.activePlayer.previous()
            }
        }

        Item {
            width: playPauseIcon.size + 8
            height: playPauseIcon.size + 8
            anchors.verticalCenter: parent.verticalCenter

            PlayPauseIcon {
                id: playPauseIcon
                playing: root.activePlayer ? root.activePlayer.isPlaying : false
                color: "white"
                anchors.centerIn: parent
            }

            TapHandler {
                enabled: root.hasPlayer
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onTapped: root.activePlayer.togglePlaying()
            }
        }

        Item {
            width: skipForwardIcon.size + 8
            height: skipForwardIcon.size + 8
            anchors.verticalCenter: parent.verticalCenter

            SkipForwardIcon {
                id: skipForwardIcon
                color: "white"
                anchors.centerIn: parent
            }

            TapHandler {
                enabled: root.hasPlayer
                acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
                onTapped: root.activePlayer.next()
            }
        }

        Text {
            text: root.activePlayer
                ? (root.activePlayer.trackTitle || "Unknown") + " — " + (root.activePlayer.trackArtist || "Unknown")
                : ""
            color: "white"
            font.family: Fonts.family
            font.pixelSize: 14
            font.weight: Fonts.weightBaseline
            elide: Text.ElideRight
            width: 240
            maximumLineCount: 1
            anchors.verticalCenter: parent.verticalCenter
        }
        }
    }
}
