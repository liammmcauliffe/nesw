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

    // Window is taller than the visible notch so horizontal scroll / drag have
    // vertical room, but only the notch height is reserved (exclusiveZone) and
    // only the masked region is interactive, so the look is unchanged.
    implicitHeight: expandedHitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    exclusiveZone: notchHeight
    WlrLayershell.namespace: "nesw-notch"

    // Notch size
    readonly property int collapsedWidth: 200
    readonly property int expandedWidth: 300
    readonly property int notchHeight: 34
    readonly property int expandedHitHeight: 120 // invisible interactive area while open
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

    // The workspace shown by the ruler. Usually equals activeWs, but can be
    // updated from early raw events to start the notch animation sooner.
    property int displayedWs: activeWs

    // Ruler runs 1..rulerMax, growing as you move to higher workspaces
    readonly property int rulerMax: Math.max(displayedWs, activeWs, maxOccupied) + rulerBuffer

    // Expand + restart the auto-collapse timer whenever the workspace changes
    onActiveWsChanged: {
        displayedWs = activeWs;
        reveal();
    }

    function reveal() {
        expanded = true;
        collapseTimer.restart();
    }

    function goToWorkspace(n) {
        const target = Math.max(1, Math.round(n));
        displayedWs = target;
        // This Hyprland config evaluates dispatch IPC as Lua: it wraps the
        // request in `hl.dispatch(<request>)`, so we send the Lua dispatch
        // expression rather than the raw "workspace N" string.
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + target + " })");
        reveal();
    }

    // Try to animate as soon as possible on workspace requests. Hyprland does
    // not expose swipe-progress over socket2, so this is still step-based.
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            const match = /^workspacev2>>(-?\d+),/.exec(event);
            if (!match)
                return;
            const id = Number(match[1]);
            if (!Number.isFinite(id) || id < 1)
                return;
            root.displayedWs = id;
            root.reveal();
        }
    }

    Timer {
        id: collapseTimer
        interval: 1500
        // Stay open while the pointer is hovering the notch
        onTriggered: {
            if (hoverHandler.hovered)
                return;
            root.expanded = false;
        }
    }

    // Geometry carrier for clickthrough mask updates.
    Item {
        id: hitMask
        x: (root.width - shape.width) / 2
        y: 0
        width: shape.width
        height: hit.height
        visible: false
    }

    // Click-through except the interactive region (the notch, taller while open)
    mask: Region {
        item: hitMask
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

        // Sliding tick strip
        Row {
            id: strip
            height: parent.height

            // Center the shown workspace under the pointer line
            x: content.width / 2 - (root.displayedWs - 1) * root.stepPx - root.stepPx / 2
            Behavior on x {
                NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
            }

            Repeater {
                model: root.rulerMax

                delegate: Item {
                    id: tick
                    required property int index
                    readonly property int wsNumber: index + 1
                    readonly property bool isActive: wsNumber === root.displayedWs
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
            text: root.displayedWs
            color: Colours.palette.m3primary
            font.pixelSize: 18
            font.bold: true
            anchors.left: content.horizontalCenter
            anchors.leftMargin: 6
            anchors.verticalCenter: content.verticalCenter
        }
    }

    // Transparent interactive area. Grows taller than the visible notch while
    // the switcher is open so 2-finger horizontal scroll and click-drag have
    // vertical room; the visuals above never change.
    Item {
        id: hit
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.notchWidth
        height: root.expanded ? root.expandedHitHeight : root.notchHeight
        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

        // Accumulator so one "notch" of scroll = one workspace, for both mouse
        // wheels (discrete) and touchpads (many small high-res deltas).
        property real wheelAccum: 0
        readonly property real wheelStep: 120

        function consumeWheelDelta(delta) {
            if (delta === 0)
                return;

            wheelAccum += delta;
            let steps = 0;
            while (wheelAccum <= -wheelStep) {
                steps += 1;
                wheelAccum += wheelStep;
            }
            while (wheelAccum >= wheelStep) {
                steps -= 1;
                wheelAccum -= wheelStep;
            }
            if (steps !== 0)
                root.goToWorkspace(root.displayedWs + steps);
        }

        // Vertical scrolling support (mouse wheel + touchpad vertical)
        WheelHandler {
            orientation: Qt.Vertical
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                let delta = event.angleDelta.y;
                if (delta === 0)
                    delta = event.pixelDelta.y;
                hit.consumeWheelDelta(delta);
            }
        }

        // Horizontal scrolling support (touchpad 2-finger horizontal)
        WheelHandler {
            orientation: Qt.Horizontal
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onWheel: event => {
                let delta = event.angleDelta.x;
                if (delta === 0)
                    delta = event.pixelDelta.x;
                hit.consumeWheelDelta(delta);
            }
        }

        // Hovering locks the switcher open (collapse timer no-ops while hovered)
        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: {
                if (hovered) {
                    root.reveal();
                    collapseTimer.stop();
                } else if (root.expanded) {
                    collapseTimer.restart();
                }
            }
        }

        // Click-to-jump + click-drag scrub fallback. This is intentionally
        // simple and robust on laptop touchpads where DragHandler can be
        // finicky depending on tap/drag settings.
        MouseArea {
            id: dragArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            property real pressX: 0
            property int startWs: 1
            property bool dragging: false

            onPressed: mouse => {
                pressX = mouse.x;
                startWs = root.displayedWs;
                dragging = false;
                root.reveal();
            }

            onPositionChanged: mouse => {
                if (!dragArea.pressed)
                    return;

                const dx = mouse.x - pressX;
                if (Math.abs(dx) >= 4)
                    dragging = true;

                if (dragging) {
                    const target = startWs - Math.round(dx / root.stepPx);
                    if (target !== root.displayedWs)
                        root.goToWorkspace(target);
                }
            }

            onReleased: mouse => {
                if (dragging)
                    return;

                const steps = Math.round((mouse.x - hit.width / 2) / root.stepPx);
                root.goToWorkspace(root.displayedWs + steps);
            }
        }
    }
}
