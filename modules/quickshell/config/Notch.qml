pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: root

    screen: Quickshell.screens[0]

    anchors.top: true
    anchors.left: true
    anchors.right: true

    implicitHeight: notchHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Auto
    WlrLayershell.namespace: "nesw-notch"

    // Notch size
    readonly property int collapsedWidth: 200
    readonly property int expandedWidth: 300
    readonly property int notchHeight: 34
    readonly property int bottomRadius: 14
    readonly property int topRadius: 14
    readonly property color notchColor: "black"

    // Animated width: collapsed = plain notch, expanded = workspace ruler
    property bool expanded: false
    property real notchWidth: expanded ? expandedWidth : collapsedWidth
    Behavior on notchWidth {
        NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }

    // Workspace ruler config
    readonly property int wsCount: 10
    readonly property int stepPx: 46

    // Active workspace from Hyprland (clamped to 1..wsCount for display)
    readonly property int activeWs: {
        const ws = Hyprland.focusedWorkspace;
        const id = ws ? ws.id : 1;
        return Math.max(1, Math.min(root.wsCount, id));
    }

    // Expand + restart the auto-collapse timer whenever the workspace changes
    onActiveWsChanged: reveal()

    function reveal() {
        expanded = true;
        collapseTimer.restart();
    }

    function goToWorkspace(n) {
        const target = Math.max(1, Math.min(root.wsCount, n));
        // This Hyprland config evaluates dispatch IPC as Lua: it wraps the
        // request in `hl.dispatch(<request>)`, so we send the Lua dispatch
        // expression rather than the raw "workspace N" string.
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + target + " })");
        reveal();
    }

    Timer {
        id: collapseTimer
        interval: 1500
        onTriggered: root.expanded = false
    }

    // Click-through except the notch
    mask: Region {
        x: (root.width - shape.width) / 2
        y: 0
        width: shape.width
        height: shape.height
    }

    // Notch shape
    Shape {
        id: shape
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter

        width: root.notchWidth + root.topRadius * 2
        height: root.notchHeight

        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root.notchColor
            strokeWidth: 0

            startX: 0
            startY: 0

            // Top-left rounds out into the screen edge
            PathArc {
                x: root.topRadius; y: root.topRadius
                radiusX: root.topRadius; radiusY: root.topRadius
                direction: PathArc.Clockwise
            }

            // Left side
            PathLine { x: root.topRadius; y: root.notchHeight - root.bottomRadius }

            // Bottom-left
            PathArc {
                x: root.topRadius + root.bottomRadius; y: root.notchHeight
                radiusX: root.bottomRadius; radiusY: root.bottomRadius
                direction: PathArc.Counterclockwise
            }

            // Bottom edge
            PathLine { x: shape.width - root.topRadius - root.bottomRadius; y: root.notchHeight }

            // Bottom-right
            PathArc {
                x: shape.width - root.topRadius; y: root.notchHeight - root.bottomRadius
                radiusX: root.bottomRadius; radiusY: root.bottomRadius
                direction: PathArc.Counterclockwise
            }

            // Right side
            PathLine { x: shape.width - root.topRadius; y: root.topRadius }

            // Top-right rounds out into the screen edge
            PathArc {
                x: shape.width; y: 0
                radiusX: root.topRadius; radiusY: root.topRadius
                direction: PathArc.Clockwise
            }

            // Top edge
            PathLine { x: 0; y: 0 }
        }
    }

    // Workspace ruler content, drawn inside the flat part of the notch
    Item {
        id: content
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        width: root.notchWidth
        height: root.notchHeight
        clip: true

        opacity: root.expanded ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        // Scroll anywhere over the notch to change workspace
        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (event) => {
                const dir = event.angleDelta.y < 0 ? 1 : -1;
                root.goToWorkspace(root.activeWs + dir);
            }
        }

        // Sliding tick strip
        Row {
            id: strip
            height: parent.height

            // Center the active workspace under the pointer
            x: content.width / 2 - (root.activeWs - 1) * root.stepPx - root.stepPx / 2
            Behavior on x {
                NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: root.wsCount

                delegate: Item {
                    id: tick
                    required property int index
                    readonly property int wsNumber: index + 1
                    readonly property bool isActive: wsNumber === root.activeWs

                    width: root.stepPx
                    height: content.height

                    // Decorative minor ticks flanking the major tick
                    Repeater {
                        model: [-2, -1, 1, 2]
                        delegate: Rectangle {
                            required property int modelData
                            width: 1
                            height: 6
                            radius: 0.5
                            color: Colours.palette.m3onSurfaceVariant
                            opacity: 0.35
                            x: tick.width / 2 + modelData * (root.stepPx / 6) - width / 2
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 5
                        }
                    }

                    // Major tick (one per workspace)
                    Rectangle {
                        width: 2
                        height: tick.isActive ? 16 : 11
                        radius: 1
                        color: tick.isActive ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5
                        Behavior on height { NumberAnimation { duration: 180 } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        enabled: root.expanded
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.goToWorkspace(tick.wsNumber)
                    }
                }
            }
        }

        // Center pointer guide line
        Rectangle {
            width: 1.5
            height: root.notchHeight - 6
            color: Colours.palette.m3primary
            opacity: 0.5
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
        }

        // Active workspace number (the "pointer" label)
        Text {
            text: root.activeWs
            color: Colours.palette.m3primary
            font.pixelSize: 12
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 1
        }
    }
}
