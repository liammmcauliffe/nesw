pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Hyprland
import qs.common

PanelWindow {
    id: root

    screen: Constants.shellScreen
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
    readonly property int rowSpacing: 4

    readonly property var actions: [
        { label: "Logout", dispatch: "hl.dsp.exit()" },
        { label: "Suspend", command: ["systemctl", "suspend"] },
        { label: "Reboot", command: ["systemctl", "reboot"] },
        { label: "Shutdown", command: ["systemctl", "poweroff"] },
    ]

    readonly property int panelHeight: actions.length * buttonHeight
        + Math.max(0, actions.length - 1) * rowSpacing
        + panelPadding * 2

    property bool open: false

    function toggle(): void {
        open = !open;
    }

    function runAction(action): void {
        open = false;
        if (action.dispatch !== undefined)
            Hyprland.dispatch(action.dispatch);
        else
            Quickshell.execDetached(action.command);
    }

    onOpenChanged: {
        if (open) {
            list.currentIndex = 0;
            focusTimer.start();
        }
    }

    Timer {
        id: focusTimer
        interval: 30
        onTriggered: panelFocus.forceActiveFocus()
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

    KeyNavigator {
        id: panelFocus
        anchors.fill: parent
        focus: root.open
        enabled: root.open
        visible: root.open
        targetList: list
        onClose: () => { root.open = false }
        onAccept: () => {
            const action = root.actions[list.currentIndex]
            if (action)
                root.runAction(action)
        }

        Rectangle {
            anchors.centerIn: parent
            width: root.panelWidth
            height: root.panelHeight
            radius: root.panelRadius
            color: root.panelBg
            visible: root.open

            ListView {
                id: list
                anchors.fill: parent
                anchors.margins: root.panelPadding
                spacing: root.rowSpacing
                interactive: false
                clip: true
                model: root.actions
                currentIndex: 0
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

                delegate: Item {
                    id: actionRow
                    required property int index
                    required property var modelData
                    width: ListView.view.width
                    height: root.buttonHeight

                    readonly property bool active: ListView.isCurrentItem

                    Rectangle {
                        anchors.fill: parent
                        radius: root.rowRadius
                        color: Colors.m3primary
                        opacity: actionRow.active ? 0.22 : 0
                        Behavior on opacity {
                            NumberAnimation { duration: 80 }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: actionRow.modelData.label
                        font.family: Fonts.family
                        font.pixelSize: 18
                        font.weight: actionRow.active ? Fonts.weightBold : Fonts.weightBaseline
                        color: Colors.m3onSurface
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: list.currentIndex = actionRow.index
                        onClicked: root.runAction(actionRow.modelData)
                    }
                }
            }
        }
    }
}
