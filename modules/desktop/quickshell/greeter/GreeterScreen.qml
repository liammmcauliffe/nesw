pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.status

PanelWindow {
    id: root

    required property GreeterAuth auth

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "#000000"

    readonly property int statusIconSize: 26
    readonly property int statusMargin: 24
    readonly property int loginWidth: 320

    PasswdDisplayName {
        id: passwdName
    }

    Row {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: root.statusMargin
            rightMargin: root.statusMargin
        }
        spacing: 28

        BluetoothStatus {
            iconSize: root.statusIconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        NetworkStatus {
            iconSize: root.statusIconSize
            anchors.verticalCenter: parent.verticalCenter
        }

        BatteryStatus {
            iconSize: root.statusIconSize
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    GreeterClock {
        anchors.centerIn: parent
    }

    Column {
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 120
        }
        spacing: 16
        width: root.loginWidth

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 80
            height: 80
            radius: width / 2
            color: Colors.m3surfaceContainerHigh
            border.color: Colors.m3outline
            border.width: 1
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: passwdName.displayName
            font.family: Fonts.family
            font.pixelSize: 20
            font.weight: Fonts.weightSemiBold
            color: "white"
        }

        TextInput {
            id: passwordField
            width: parent.width
            height: 44
            text: root.auth.password
            echoMode: TextInput.Password
            font.family: Fonts.family
            font.pixelSize: 16
            color: Colors.m3onSurface
            selectionColor: Colors.m3primary
            selectedTextColor: Colors.m3onPrimary
            verticalAlignment: TextInput.AlignVCenter
            leftPadding: 12
            rightPadding: 12
            clip: true

            onTextChanged: root.auth.password = text
            onAccepted: root.auth.submit()

            Rectangle {
                z: -1
                anchors.fill: parent
                radius: 8
                color: Colors.m3surfaceContainerHigh
                border.color: Colors.m3outline
            }

            Text {
                anchors {
                    left: parent.left
                    leftMargin: 12
                    verticalCenter: parent.verticalCenter
                }
                text: "Enter Password"
                font: passwordField.font
                color: Colors.m3onSurfaceVariant
                visible: !passwordField.text && !passwordField.activeFocus
            }
        }

        Text {
            width: parent.width
            visible: root.auth.statusText !== ""
            text: root.auth.statusText
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            font.family: Fonts.family
            font.pixelSize: 14
            color: Colors.m3error
        }
    }

    Connections {
        target: root.auth
        function onPasswordRejected(): void {
            passwordField.text = "";
            passwordField.forceActiveFocus();
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
