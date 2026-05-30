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
    readonly property int stepPx: 46
    readonly property int rulerBuffer: 5 // extra ticks of runway past the last one
    readonly property int frameInset: 4 // matches Border.qml frame thickness

    // Active workspace from Hyprland (uncapped)
    readonly property int activeWs: {
        const ws = Hyprland.focusedWorkspace;
        return ws ? Math.max(1, ws.id) : 1;
    }

    // Highest existing workspace id
    readonly property int maxOccupied: {
        let m = 0;
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++)
            if (list[i].id > m)
                m = list[i].id;
        return m;
    }

    // Set of occupied workspace ids, for highlighting populated workspaces
    readonly property var occupied: {
        const s = {};
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++)
            s[list[i].id] = true;
        return s;
    }

    // Ruler runs 1..rulerMax, growing as you move to higher workspaces
    readonly property int rulerMax: Math.max(activeWs, maxOccupied) + rulerBuffer

    // Expand + restart the auto-collapse timer whenever the workspace changes
    onActiveWsChanged: reveal()

    function reveal() {
        expanded = true;
        collapseTimer.restart();
    }

    function goToWorkspace(n) {
        const target = Math.max(1, Math.round(n));
        // This Hyprland config evaluates dispatch IPC as Lua: it wraps the
        // request in `hl.dispatch(<request>)`, so we send the Lua dispatch
        // expression rather than the raw "workspace N" string.
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + target + " })");
        reveal();
    }

    Timer {
        id: collapseTimer
        interval: 1500
        // Stay open while the pointer is hovering the notch
        onTriggered: {
            if (wsMouse.containsMouse)
                return;
            root.expanded = false;
        }
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

        // Scroll to switch: vertical wheel or 2-finger horizontal scroll
        WheelHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: (event) => {
                const dx = event.angleDelta.x;
                const dy = event.angleDelta.y;
                const delta = Math.abs(dx) > Math.abs(dy) ? dx : dy;
                if (delta === 0)
                    return;
                root.goToWorkspace(root.activeWs + (delta < 0 ? 1 : -1));
            }
        }

        // Click to jump, or click-drag to scrub workspaces live
        MouseArea {
            id: wsMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            property real pressX: 0
            property int pressWs: 1
            property bool dragging: false

            // Hovering locks the switcher open (cancels the collapse timer)
            onContainsMouseChanged: {
                if (containsMouse)
                    collapseTimer.stop();
                else if (root.expanded)
                    collapseTimer.restart();
            }

            onPressed: mouse => {
                pressX = mouse.x;
                pressWs = root.activeWs;
                dragging = false;
                root.reveal();
            }
            onPositionChanged: mouse => {
                if (!pressed)
                    return;
                const dx = mouse.x - pressX;
                if (Math.abs(dx) > 4)
                    dragging = true;
                if (dragging) {
                    const target = pressWs - Math.round(dx / root.stepPx);
                    if (target !== root.activeWs)
                        root.goToWorkspace(target);
                }
            }
            onReleased: mouse => {
                if (!dragging) {
                    const steps = Math.round((mouse.x - width / 2) / root.stepPx);
                    root.goToWorkspace(root.activeWs + steps);
                }
            }
        }

        // Sliding tick strip
        Row {
            id: strip
            height: parent.height

            // Center the active workspace under the pointer line
            x: content.width / 2 - (root.activeWs - 1) * root.stepPx - root.stepPx / 2
            Behavior on x {
                NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: root.rulerMax

                delegate: Item {
                    id: tick
                    required property int index
                    readonly property int wsNumber: index + 1
                    readonly property bool isActive: wsNumber === root.activeWs
                    readonly property bool isOccupied: root.occupied[wsNumber] === true

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
                            opacity: 0.3
                            x: tick.width / 2 + modelData * (root.stepPx / 6) - width / 2
                            anchors.verticalCenter: tick.verticalCenter
                        }
                    }

                    // Major tick: the active one grows full-height (inset by the
                    // frame thickness top & bottom) and takes the accent colour.
                    Rectangle {
                        width: 2
                        height: tick.isActive ? content.height - root.frameInset * 2
                              : tick.isOccupied ? 14 : 9
                        radius: 1
                        color: tick.isActive ? Colours.palette.m3primary
                             : tick.isOccupied ? Colours.palette.m3onSurface
                             : Colours.palette.m3onSurfaceVariant
                        opacity: tick.isActive || tick.isOccupied ? 1 : 0.5
                        anchors.horizontalCenter: tick.horizontalCenter
                        anchors.verticalCenter: tick.verticalCenter
                        Behavior on height { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 180 } }
                    }
                }
            }
        }

        // Active workspace number, offset to the right of the active line
        Text {
            text: root.activeWs
            color: Colours.palette.m3primary
            font.pixelSize: 18
            font.bold: true
            anchors.left: content.horizontalCenter
            anchors.leftMargin: 6
            anchors.verticalCenter: content.verticalCenter
        }
    }
}
