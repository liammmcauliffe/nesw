pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// logout dialog
PanelWindow {
    id: root

    screen: Quickshell.screens[0]
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    color: "transparent"
    visible: true

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "logout_dialog"
    WlrLayershell.keyboardFocus: root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property color panelBg: "#f0000000"
    readonly property int panelWidth: 320
    readonly property int buttonHeight: 52
    readonly property int panelPadding: 16
    readonly property int panelRadius: 20
    readonly property int rowRadius: 8

    readonly property var actions: [
        { label: "Logout", command: ["hyprctl", "dispatch", "exit"] },
        { label: "Suspend", command: ["systemctl", "suspend"] },
        { label: "Reboot", command: ["systemctl", "reboot"] },
        { label: "Shutdown", command: ["systemctl", "poweroff"] },
    ]

    property bool open: false

    function toggle(): void {
        open = !open;
    }

    function runAction(command): void {
        open = false;
        Quickshell.execDetached(command);
    }

    IpcHandler {
        target: "logout"
        function toggle(): void {
            root.toggle();
        }
        function show(): void {
            root.open = true;
        }
        function hide(): void {
            root.open = false;
        }
    }

    Item {
        id: hitMask
        x: 0
        y: 0
        width: root.open ? root.width : 0
        height: root.open ? root.height : 0
        visible: false
    }

    mask: Region {
        item: hitMask
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.open
        onClicked: root.open = false
    }

    Item {
        anchors.fill: parent
        focus: root.open
        enabled: root.open
        visible: root.open

        Keys.onPressed: function (event) {
            if (event.key === Qt.Key_Escape) {
                root.open = false;
                event.accepted = true;
            }
        }

        Rectangle {
            anchors.centerIn: parent
            width: root.panelWidth
            height: actionColumn.height + root.panelPadding * 2
            radius: root.panelRadius
            color: root.panelBg
            visible: root.open

            Column {
                id: actionColumn
                anchors.centerIn: parent
                width: parent.width - root.panelPadding * 2
                spacing: 4

                Repeater {
                    model: root.actions

                    Rectangle {
                        required property var modelData
                        width: actionColumn.width
                        height: root.buttonHeight
                        radius: root.rowRadius
                        color: actionMouse.pressed ? "#22ffffff" : actionMouse.containsMouse ? "#11ffffff" : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.label
                            font.family: Fonts.family
                            font.pixelSize: 18
                            font.weight: Fonts.weightBaseline
                            color: Colors.palette.m3onSurface
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: root.runAction(modelData.command)
                        }
                    }
                }
            }
        }
    }
}
