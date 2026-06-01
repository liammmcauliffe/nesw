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

    implicitHeight: hitHeight
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Top
    exclusiveZone: notchHeight
    WlrLayershell.namespace: "nesw-notch"

    // Notch
    readonly property int collapsedWidth: 200
    readonly property int expandedWidth: 300
    readonly property int notchHeight: 34
    readonly property int hitHeight: 120
    readonly property int bottomRadius: 14
    readonly property int topRadius: 14
    readonly property color notchColor: "black"

    // Ruler
    readonly property int stepPx: 46
    readonly property int rulerBuffer: 5
    readonly property int frameInset: 4

    property bool expanded: false
    property real notchWidth: expanded ? expandedWidth : collapsedWidth

    readonly property int activeWs: {
        const ws = Hyprland.focusedWorkspace;
        return ws ? Math.max(1, ws.id) : 1;
    }

    readonly property int maxOccupied: {
        let m = 0;
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            const id = list[i].id;
            if (id > m)
                m = id;
        }
        return m;
    }

    readonly property var occupied: {
        const s = {};
        const list = Hyprland.workspaces.values;
        for (let i = 0; i < list.length; i++) {
            const id = list[i].id;
            if (id > 0)
                s[id] = true;
        }
        return s;
    }

    readonly property int rulerMax: Math.max(activeWs, maxOccupied) + rulerBuffer

    onActiveWsChanged: reveal()

    function reveal() {
        expanded = true;
        collapseTimer.restart();
    }

    function goToWorkspace(n) {
        const target = Math.max(1, Math.round(n));
        Hyprland.dispatch("hl.dsp.focus({ workspace = " + target + " })");
        reveal();
    }

    Timer {
        id: collapseTimer
        interval: 1500
        onTriggered: {
            if (hoverHandler.hovered)
                return;
            root.expanded = false;
        }
    }

    Behavior on notchWidth {
        NumberAnimation { duration: 280; easing.type: Easing.OutCubic }
    }

    // Clickthrough
    Item {
        id: hitMask
        x: (root.width - shape.width) / 2
        y: 0
        width: shape.width
        height: hit.height
        visible: false
    }

    mask: Region {
        item: hitMask
    }

    // Shape
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

            PathArc {
                x: root.topRadius
                y: root.topRadius
                radiusX: root.topRadius
                radiusY: root.topRadius
                direction: PathArc.Clockwise
            }

            PathLine {
                x: root.topRadius
                y: root.notchHeight - root.bottomRadius
            }

            PathArc {
                x: root.topRadius + root.bottomRadius
                y: root.notchHeight
                radiusX: root.bottomRadius
                radiusY: root.bottomRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: shape.width - root.topRadius - root.bottomRadius
                y: root.notchHeight
            }

            PathArc {
                x: shape.width - root.topRadius
                y: root.notchHeight - root.bottomRadius
                radiusX: root.bottomRadius
                radiusY: root.bottomRadius
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: shape.width - root.topRadius
                y: root.topRadius
            }

            PathArc {
                x: shape.width
                y: 0
                radiusX: root.topRadius
                radiusY: root.topRadius
                direction: PathArc.Clockwise
            }

            PathLine { x: 0; y: 0 }
        }
    }

    // Content
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

        Row {
            id: strip
            height: parent.height
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

                        Behavior on height {
                            NumberAnimation { duration: 180; easing.type: Easing.OutCubic }
                        }

                        Behavior on color {
                            ColorAnimation { duration: 180 }
                        }
                    }
                }
            }
        }

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

    // Input
    Item {
        id: hit
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.notchWidth
        height: root.expanded ? root.hitHeight : root.notchHeight

        Behavior on height {
            NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
        }

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
                root.goToWorkspace(root.activeWs + steps);
        }

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
    }
}
