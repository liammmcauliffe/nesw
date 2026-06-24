import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Greetd

ShellRoot {
    id: root

    readonly property string user: "liam"

    PanelWindow {
        screen: Quickshell.screens[0]

        anchors.top: true
        anchors.bottom: true
        anchors.left: true
        anchors.right: true

        color: "#09090b"

        TextField {
            id: passwordField
            anchors.centerIn: parent
            width: 280
            placeholderText: "Password"
            echoMode: TextInput.Password
            focus: true
            onAccepted: root.submit()
        }

        Text {
            id: errorText
            anchors.top: passwordField.bottom
            anchors.topMargin: 8
            anchors.horizontalCenter: passwordField.horizontalCenter
            color: "#f87171"
            visible: text.length > 0
        }
    }

    function submit() {
        errorText.text = ""
        if (passwordField.text.length === 0) {
            return
        }
        Greetd.createSession(root.user)
    }

    Connections {
        target: Greetd

        function onAuthMessage(message, error, responseRequired, echoResponse) {
            if (error) {
                errorText.text = message
            } else if (responseRequired) {
                Greetd.respond(passwordField.text)
            }
        }

        function onAuthFailure(message) {
            errorText.text = message
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }

        function onReadyToLaunch() {
            Greetd.launch(["start-hyprland"])
        }
    }
}
